library(stringr)
library(readr)
library(readxl)
library(dplyr)
library(pbapply)
library(foreign)
library(haven)
library(tidyr)

# paper-level  characteristics 
# Investigator’s intellectual focus
related_xwalk <- select(related_xwalk, author_id, pmid, pubyear,month, rltd_pmid,rltd_year,rltd_month,rltd_scr )
chemists_rltd <- related_xwalk
chemists_rltd<-subset(chemists_rltd, pmid!= rltd_pmid) # drop slf related papers 
chemists_rltd<-subset(chemists_rltd, !is.na(rltd_scr)) 
chemists_rltd<- subset(chemists_rltd, chemists_rltd$rltd_pmid!="")
chemists_rltd<-subset(chemists_rltd, !is.na(rltd_pmid))
chemists_rltd<-subset(chemists_rltd, !is.na(rltd_year))
chemists_rltd<-subset(chemists_rltd, !is.na(pubyear))
##keep 3 years before focal paper 
chemists_rltd<- subset(chemists_rltd,  (rltd_year < pubyear) | (rltd_year = pubyear & rltd_month< month ) ) ### only keep papers pub before the focal paper 
chemists_rltd<- chemists_rltd %>% left_join(select(alltop_pub1, rltd_pmid=pmid, author_check=author_id)%>%distinct(), by = "rltd_pmid") ### alltop_pub1 is all publications for all PIs
chemists_rltd$slf<- ifelse(chemists_rltd$author_id==chemists_rltd$author_check,1,0)
chemists_rltd$slf<- ifelse(is.na(chemists_rltd$slf), 0, chemists_rltd$slf)
chemists_rltd<-select(chemists_rltd,-c(author_check))%>%distinct()
chemists_rltd<-chemists_rltd%>%group_by(pmid, author_id,rltd_pmid)%>%mutate(slf=max(slf))%>%distinct()
chemists_rltd<-chemists_rltd%>%group_by(pmid, author_id,rltd_pmid)%>%mutate(n=n())
chemists_rltd<-select(chemists_rltd, author_id, pmid,rltd_pmid,rltd_scr, slf ) %>%distinct()
chemists_rltd<- chemists_rltd%>%group_by(pmid, author_id) %>%mutate(T_rltd=n(), own_rltf=sum(slf))
# own_rltf_tim_pcr: the investigator’s importance for the subfield
chemists_rltd$own_rltf_tim_pcr<-chemists_rltd$own_rltf/chemists_rltd$T_rltd ### ownrltd papers %
chemists_rltd_final<-select(chemists_rltd, pmid, author_id,own_rltf_tim_pcr )%>%distinct()
### the field is important to PI
chemists_rltd$year_1<-chemists_rltd$pubyear-1 
chemists_rltd<-chemists_rltd%>%left_join(select(csum_751chemists_final, author_id, year, csum_inpubmed)%>%distinct(),by = c("author_id"="author_id","year_1"="year"))
chemists_rltd$subfield_csum_pcto2o<- chemists_rltd$own_rltf/chemists_rltd$csum_inpubmed 
chemists_rltd_final<-select(chemists_rltd, pmid,own_rltf_tim_pcr,subfield_csum_pcto2o )%>%distinct()
# merge to estimation data set 
matched_papers_obs<-matched_papers_obs%>%left_join(chemists_rltd_final, by = "pmid") # 
