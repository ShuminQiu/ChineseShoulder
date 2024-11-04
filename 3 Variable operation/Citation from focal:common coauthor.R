library(stringr)
library(readr)
library(readxl)
library(dplyr)
library(pbapply)
library(foreign)
library(haven)
library(tidyr)
# paper pair characteristics
# citation from focal coauthor 
# load authors' name for all PI papers 
## focal co-author names 
# focal_author <- overall_authors_2019 %>%
#   filter(pmid %in% alltop_pub$pmid)
# focal_author<- alltop_pub%>%left_join(select(focal_author, pmid, seq,author_seq, lastname,initials, suffix, forename )%>%distinct(),by ="pmid")
# # # # ##exclude focal chemists
focal_author<-subset(focal_author, author_postn!=author_seq) ## exclude top chemists 
focal_author$lastname<-toupper(focal_author$lastname)
focal_author$forename<-toupper(focal_author$forename)
focal_author$initials<-toupper(focal_author$initials)
# 
focal_author_inmatch<- select(matched_papers_obs, author_id,wos_uid)%>%left_join(focal_author, by = c("author_id","wos_uid"="wos_id")) #### 
rltd_id<-  select(matched_papers_obs, rltd_wos_uid=rltd_wos_uid.x)%>%distinct()
rltdpair_athr<- select(matched_papers_obs, wos_uid, rltd_wos_uid=rltd_wos_uid.x)%>%left_join(select(focal_author_inmatch,author_id,wos_uid,seq_no=author_seq,last_name=lastname, first_name=forename, initials)%>%distinct(),by= "wos_uid")
# load author names for citing papers (risk_names)
risk_names$first_name<-toupper(risk_names$first_name)
risk_names$last_name<-toupper(risk_names$last_name)
rltd_author_inmatch<-risk_names%>%filter(wos_uid %in% rltd_id$rltd_wos_uid)
rltdpair_athr<-rltdpair_athr%>%left_join(select(rltd_author_inmatch, rltd_wos_uid=wos_uid,rltd_seq_no=seq_no,rltd_last_name=last_name, rltd_first_name=first_name )%>%distinct(),by= c("rltd_wos_uid"= "rltd_wos_uid"))
# rltdpair_athr$lastname<-toupper(rltdpair_athr$lastname)
# rltdpair_athr$initials<-toupper(rltdpair_athr$initials)
# rltdpair_athr$suffix<-toupper(rltdpair_athr$suffix)
# rltdpair_athr$forename<-toupper(rltdpair_athr$forename)
# rltdpair_athr$rltd_lastname<-toupper(rltdpair_athr$rltd_lastname)
# rltdpair_athr$rltd_initials <-toupper(rltdpair_athr$rltd_initials)
# rltdpair_athr$rltd_suffix<-toupper(rltdpair_athr$rltd_suffix)
# rltdpair_athr$rltd_forename<-toupper(rltdpair_athr$rltd_forename)
rltdpair_athr$first_name<-gsub("[^A-Za-z]","", rltdpair_athr$first_name) 
rltdpair_athr$rltd_first_name<-gsub("[^A-Za-z]","", rltdpair_athr$rltd_first_name) 
rltdpair_athr$initials<-gsub("[^A-Za-z]","", rltdpair_athr$initials) 
rltdpair_athr$focal_coauthor<- ifelse(rltdpair_athr$last_name==rltdpair_athr$rltd_last_name & rltdpair_athr$first_name==rltdpair_athr$rltd_first_name,1,0)
rltdpair_athr$focal_coauthor<- ifelse(rltdpair_athr$last_name==rltdpair_athr$rltd_last_name & rltdpair_athr$initials==rltdpair_athr$rltd_first_name,1,rltdpair_athr$focal_coauthor)

rltdpair_athr_fccathr<-subset(rltdpair_athr,focal_coauthor==1 )
rltdpair_athr_fccathr<-select(rltdpair_athr_fccathr, author_id,wos_uid,rltd_wos_uid,focal_coauthor)%>%distinct()

matched_papers_obs<-matched_papers_obs%>%left_join(rltdpair_athr_fccathr, by = c("author_id","wos_uid","rltd_wos_uid.x"="rltd_wos_uid"))
matched_papers_obs$focal_coauthor<-ifelse(is.na(matched_papers_obs$focal_coauthor),0,matched_papers_obs$focal_coauthor)

##citation from common coauthor (past coauthor)
# load raw data (common_coauthor) of author names for PI's past publications, and map common coauthor names to citing names (risk names) 
common_coauthor<- select(common_coauthor, author_id, lastname,first_name)%>%distinct()  ## these names are PI's coauthors 

rltd_author_inmatch<-risk_names%>%filter(wos_uid %in% rltd_id$rltd_wos_uid)
rltd_author_inmatch<- rltd_author_inmatch%>%left_join(common_coauthor, by = c("last_name","first_name")) ## 
rltdauthor_authorid<-rltd_author_inmatch
rltdauthor_authorid<-subset(rltdauthor_authorid, !is.na(rltdauthor_authorid$author_id)) ## matched paper, means citations from commin coauthors 
rltdauthor_authorid_final<-rltdauthor_authorid
rltdauthor_authorid_final<-select(rltdauthor_authorid_final, author_id, rltd_pmid)%>%distinct()
rltdauthor_authorid_final$common_coauthor<-1
matched_papers_obs<-matched_papers_obs%>%left_join(rltdauthor_authorid_final, by = c("author_id","rltd_pmid"))
matched_papers_obs$common_coauthor[is.na(matched_papers_obs$common_coauthor)]<-0
matched_papers_obs$common_coauthor[matched_papers_obs$focal_coauthor==1]<-0
