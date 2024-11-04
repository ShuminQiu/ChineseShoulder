library(stringr)
library(readr)
library(readxl)
library(dplyr)
library(pbapply)
library(foreign)
library(haven)
library(tidyr)
# notes:some simple variables (see below) are coded based on raw data from Web of Science, CEPII data set, Google map API. 
# (1) samejournal: citation from same journal 
# (2) US_reprint_or_1st: US First/Reprinted Cited Author   
# (3) US_other_P: US Cited Author in Other Positions
# (4) i_English_prm: Investigator from English-speaking Country, manually coded. i_English_prm=1 if PI's primary working country is an English speaking country (raw data from CEPIIdata set).  
## (5) lndist: we rely on Google map API (find details below: https://developers.google.com/maps/documentation/javascript/directions?hl=zh_CN#TravelModes) to generate the distance between focal PI's city to citing cities, calculate the mean distance, and then take natural logarithm. 
## below we generate control variables that require more complex processing and calculation
# PI-year specific characteristics  
# (1) investigator cumulative publication and citation at (cited year i-1) 
# load raw data of citations: author_id*pmid*cit_pmid xwalk 
# load raw data of publications: author_id*pmid*year 
alltop_pub751 <- read_dta("alltop_pub751.dta")
alltop_pub751<-subset(alltop_pub751, orgnl ==1&nb_authrs <16)  ## original papers with authors <16 
csum_751chemists<- select(alltop_pub751,author_id)%>%distinct()
year <- seq(1947, 2019)
year$merge<-1
csum_751chemists$merge<-1
csum_751chemists<-csum_751chemists%>%left_join(year, by = "merge")
csum_751chemists<-csum_751chemists%>%left_join(alltop_pub751,by=c("author_id","year"))
csum_751chemists$pub_pubmed<-ifelse(!is.na(csum_751chemists$pmid),1,0) # in case some year, the PI did not publish. 

csum_751chemists<-select(csum_751chemists,author_id,year,pmid,wos_uid,pub_pubmed)%>%distinct()
csum_751chemists<-csum_751chemists%>%group_by(author_id,year)%>%mutate(nb_inpunmed=sum(pub_pubmed) ) # sum up nb of pubs at year i
csum_751chemists1<-select(csum_751chemists,-c(pmid,wos_uid,last_pub,pub_pubmed))%>%distinct() %>%
  group_by(author_id) %>% arrange(author_id, year) %>% mutate(csum_inpubmed=cumsum(nb_inpunmed)) # cumulative citation at year i
# for cumulative citations 
srce_ctd_pairs_pubmed2pubmed <- read_dta("srce_ctd_pairs_pubmed2pubmed.dta")
# load citation raw data 
csumcite_chemist<-select(csum_751chemists,author_id, year, pmid)%>%distinct() %>%distinct()%>%left_join(select(srce_ctd_pairs_pubmed2pubmed,pmid=srce_pmid,ctng_pmid)%>%distinct(),by="pmid")
csumcite_chemist$cit<-ifelse(!is.na(csumcite_chemist$ctng_pmid),1,0)

csumcite_chemist<-csumcite_chemist%>%left_join(select(pubmed_xtrct_flat, ctng_pmid=pmid,cityear=year)%>%distinct(),by="ctng_pmid")
# pubmed_xtrct_flat is the raw data of paper basic characteristis for all PubMed papers 
csumcite_chemist<-subset(csumcite_chemist,cit==0|!is.na(cityear)) 
csumcite_chemist$cityear<- ifelse(is.na(csumcite_chemist$ctng_pmid) & is.na(csumcite_chemist$cityear),0,csumcite_chemist$cityear)
csumcite_chemist$cityear<- ifelse(!is.na(csumcite_chemist$ctng_pmid) & is.na(csumcite_chemist$cityear),9999,csumcite_chemist$cityear) ### 4.16% ref_id do not have publication year info

csumcite_chemist<-csumcite_chemist%>%left_join(select(alltop_pub751, ctngauthor_id=author_id, ctng_pmid=pmid,merge)%>%distinct(), by = "ctng_pmid")
csumcite_chemist$slf<-ifelse(csumcite_chemist$author_id==csumcite_chemist$ctngauthor_id,1,0)
csumcite_chemist$slf[is.na(csumcite_chemist$slf)]<-0 ## self citations 

csumcite_chemist_final<-csumcite_chemist%>%group_by(author_id,cityear)%>%summarise(nb_cit=sum(cit),nb_slf=sum(slf))
csumcite_chemist_final$nb_cit_nslf<-csumcite_chemist_final$nb_cit-csumcite_chemist_final$nb_slf

csumcite_chemist_final1<-select(csumcite_chemist, author_id,year)%>%distinct()%>%left_join(csumcite_chemist_final, by =c("author_id"="author_id","year"="cityear"))
csumcite_chemist_final1$nb_cit[is.na(csumcite_chemist_final1$nb_cit)]<-0
csumcite_chemist_final1$nb_slf [is.na(csumcite_chemist_final1$nb_slf)]<-0
csumcite_chemist_final1$nb_cit_nslf[is.na(csumcite_chemist_final1$nb_cit_nslf)]<-0

csumcite_chemist_final1<-csumcite_chemist_final1 %>%
  group_by(author_id) %>% arrange(author_id, year) %>% mutate(csum_cit=cumsum(nb_cit),csum_cit_nslf=cumsum(nb_cit_nslf))

csum_751chemists_final<- csum_751chemists1%>%left_join(csumcite_chemist_final1,by = c("author_id","year"))
csum_751chemists_final<-csum_751chemists_final%>%ungroup()
