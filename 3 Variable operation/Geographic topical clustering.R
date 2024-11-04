library(stringr)
library(readr)
library(readxl)
library(dplyr)
library(pbapply)
library(foreign)
library(haven)
library(tidyr)

# paper-level  characteristics 
# Geographic topical clustering
# load raw data of PMRA: related_xwalk
related_xwalk <- select(related_xwalk, author_id, pmid, pubyear,month, rltd_pmid,rltd_year,rltd_month,rltd_scr )
subfield_intensity<-related_xwalk
subfield_intensity<-subset(subfield_intensity, pmid!= rltd_pmid) 
subfield_intensity<-subset(subfield_intensity, !is.na(rltd_scr))
subfield_intensity<-subset(subfield_intensity, !is.na(rltd_year))
subfield_intensity<-subset(subfield_intensity, !is.na(pubyear))
##keep related papers published 3 years before  focal paper 
subfield_intensity<- subset(subfield_intensity,  (rltd_year < pubyear) | (rltd_year = pubyear & rltd_month< month ) ) ### only keep papers pub before the focal paper 
subfield_intensity$for_intens <- ifelse(subfield_intensity$rltd_year>= subfield_intensity$pubyear-3, 1, 0 )
subfield_intensity<- subset(subfield_intensity, rltd_scr >= 0.5) # only consider highly related papers
subfield_intensity<-subset(subfield_intensity,for_intens==1) 
## should drop PI self related papers 
check1<-select(alltop_pub1,author_id_check=author_id,pmid)%>%distinct()
check1<-check1%>%ungroup()
subfield_intensity<-subfield_intensity%>%left_join(check1,by =c("rltd_pmid"="pmid"))
subfield_intensity$slf<- ifelse(subfield_intensity$author_id==subfield_intensity$author_id_check,1,0)
subfield_intensity$slf<- ifelse(is.na(subfield_intensity$slf), 0, subfield_intensity$slf)
subfield_intensity<- subfield_intensity %>% group_by(pmid, rltd_pmid) %>% mutate(slf=max(slf))   
subfield_intensity<- subset(subfield_intensity, slf==0)  
subfield_intensity<- select(subfield_intensity,author_id, pmid, rltd_pmid,rltd_scr) %>%distinct()
subfield_intensity<- subfield_intensity %>% group_by( pmid, author_id ) %>% mutate(glbl_intens = sum(rltd_scr )) 
# ##### home intens and ROW intens 
subfield_intensity<-subfield_intensity%>%left_join(select(pubmed_xtrct_flat,pmid,wos_uid )%>%distinct(),by="pmid")
subfield_intensity<-subfield_intensity%>%left_join(select(pubmed_xtrct_flat,rltd_pmid=pmid,rltd_wos_uid=wos_uid )%>%distinct(),by="rltd_pmid")
subfield_intensity<-subfield_intensity%>%left_join(select(full_chemists_CV,author_id,cntry_prmry_org )%>%distinct(),by="author_id")   ## author_id's country
# load raw data of papers' address of citing papers: wos_address 
subfield_intensity<- subfield_intensity %>% left_join(select(wos_addresses, wos_uid,country,addresses_count)%>%distinct(), by = c("rltd_wos_uid"="wos_uid")) ## citing id's country 
# need manually standardized for country data, then: 
subfield_intensity$home <- ifelse(subfield_intensity$cntry_prmry_org ==subfield_intensity$country,1,0 )
subfield_intensity$USA<-ifelse(subfield_intensity$country=="USA",1,0 )
subfield_intensity$ROW<-ifelse(subfield_intensity$home==0&subfield_intensity$USA==0,1,0 )
check<-subset(subfield_intensity, is.na(home))
subfield_intensity<-subset(subfield_intensity, !is.na(home))
subfield_intensity<- subfield_intensity %>% group_by(pmid, author_id, rltd_pmid)%>% mutate(home = sum(home), USA=sum(USA), ROW=sum(ROW))  ## 

subfield_intensity$home_frct<-subfield_intensity$home/subfield_intensity$addresses_count
subfield_intensity$USA_frct<-subfield_intensity$USA/subfield_intensity$addresses_count
subfield_intensity$ROW_frct<-subfield_intensity$ROW/subfield_intensity$addresses_count
# subfield_intensity$check<-subfield_intensity$home_frct+subfield_intensity$USA_frct+subfield_intensity$ROW_frct
subfield_intensity<-select(subfield_intensity, author_id, pmid, rltd_pmid, home_frct,USA_frct,ROW_frct, rltd_scr)%>%distinct()
subfield_intensity$homescr<-subfield_intensity$rltd_scr*subfield_intensity$home_frct
subfield_intensity$frgscr<-subfield_intensity$rltd_scr*subfield_intensity$ROW_frct
subfield_intensity$usascr<-subfield_intensity$rltd_scr*subfield_intensity$USA_frct
# 
subfield_intensity<- subfield_intensity %>% group_by( pmid,author_id) %>% mutate(allhome_intens = sum(homescr ),allforeign_intens=sum(frgscr), usa_intens=sum(usascr))
subfield_intensity_final<-select(subfield_intensity, author_id, pmid, allforeign_intens, allhome_intens, usa_intens, glbl_intens )%>%distinct()
matched_papers_obs<-matched_papers_obs%>%left_join(subfield_intensity_final, by = c("author_id", "pmid"))
