library(stringr)
library(readr)
library(readxl)
library(dplyr)
library(pbapply)
library(foreign)
library(haven)
library(tidyr)

# paper-level  characteristics 
# (1) retraction intensity 
# load retraction raw data (retraction.dta): pmid  that are being retracted 
retraction<-select(retraction, pmid, unreliable_narrow=retracted)
# load raw data (related_xwalk.dta) of related scores from pubmed:  focal paper(pmid)'s related paper (rltd_pmid) with related score ( rltd_scr)
related_xwalk <- select(related_xwalk, author_id, pmid, pubyear,month, rltd_pmid,rltd_year,rltd_month,rltd_scr )
subfield_retrct <- select(matched_papers_obs, pmid)%>%distinct()
subfield_retrct<-subfield_retrct%>%left_join(related_xwalk, by = "pmid") 
subfield_retrct<-subset(subfield_retrct, pmid!= rltd_pmid) 
subfield_retrct<-subset(subfield_retrct, !is.na(rltd_scr))
subfield_retrct<-subset(subfield_retrct, !is.na(rltd_year))
subfield_retrct<-subset(subfield_retrct, !is.na(pubyear))
#keep pubs before and after focal paper 
subfield_retrct<- subset(subfield_retrct,  (rltd_year < pubyear) | (rltd_year = pubyear & rltd_month< month ) ) ### only keep papers pub before the focal paper 
subfield_retrct<-subfield_retrct%>%left_join(retraction, by = c("rltd_pmid" ="pmid") )

subfield_retrct$retracted[is.na(subfield_retrct$retracted)]<- 0 
subfield_retrct$nrrw_dum<-ifelse(subfield_retrct$retracted>0,1,0)
subfield_retrct<- subfield_retrct %>%group_by(pmid)%>%mutate(nrrw_dum=max(nrrw_dum))
subfield_retrct<-select(subfield_retrct,pmid, nrrw_dum)%>%distinct()
# merge to estimation data set 
matched_papers_obs<-matched_papers_obs%>%left_join(subfield_retrct, by = "pmid") # 

