library(stringr)
library(readr)
library(readxl)
library(dplyr)
library(pbapply)
library(foreign)
library(haven)
library(tidyr)
# paper pair characteristics
# citation from same ethnicity 
#######ethnicity data 
# we map a scholar’s last name to its ethnic origins based on the algorithm pioneered by Nguyen (2019). Based on her algorithm, we can generate a relationship between 
# last name and country, with the probability that  a last name corresponds to a particular ethnic origin 
## we load the data: surname_ethnic_prob_10_split that shows the xalks betweenlast name and country, with probability (value) 
ij_cite_ethnicity_10 <- select(matched_papers_obs, pmid,rltd_pmid, author_id, cntry_prmry_org) %>% 
  left_join(risk_names, by = "rltd_pmid" )
ij_cite_ethnicity_10$last_name <- toupper(ij_cite_ethnicity_10$last_name)
ij_cite_ethnicity_10 <- ij_cite_ethnicity_10 %>% left_join(select(surname_ethnic_prob_10_split, surname_full,Country,value=value1)%>%distinct(),by = c("last_name" = "surname_full"))
ij_cite_ethnicity_10 <- ij_cite_ethnicity_10 %>% ungroup() %>% distinct()
# standardizing countries 
ij_cite_ethnicity_10$Country<-toupper(ij_cite_ethnicity_10$Country)
ij_cite_ethnicity_10<-ij_cite_ethnicity_10%>%left_join(countrystandizedfinal,by = c("Country" = "country"))
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="GREAT BRITAIN"]<-  "UK"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="VIET NAM"]<-  "VIETNAM"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="BOSNIA"]<-  "BOSNIA"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="BOSNIA HERZEGOVINA"]<-  "BOSNIA"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="DOMINICAN REPUBLIC"]<-  "DOMINICAN REPUBLIC"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="GEORGIA"]<-  "GEORGIA"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="NORTHERN IRELAND"]<-  "UK"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="RUSSIAN FEDERATION"]<-  "RUSSIA"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="SERBIA AND MONTENEGRO"]<-  "SERBIA AND MONTENEGRO"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="TRINIDAD AND TOBAGO"]<-  "TRINIDAD AND TOBAGO"
ij_cite_ethnicity_10$standardized[ij_cite_ethnicity_10$Country=="UNITED STATES"]<-  "USA"
ij_cite_ethnicity_10$Country<-ifelse(!is.na(ij_cite_ethnicity_10$standardized),ij_cite_ethnicity_10$standardized,ij_cite_ethnicity_10$Country)
ij_cite_ethnicity_10<-select(ij_cite_ethnicity_10, -standardized)%>%distinct()
ij_cite_ethnicity_10$Country[ij_cite_ethnicity_10$Country=="CZECH"]<-"CZECH REPUBLIC"
ij_cite_ethnicity_10$ij_same_ethnic <- ifelse(ij_cite_ethnicity_10$cntry_prmry_org == ij_cite_ethnicity_10$Country,1,0 )
ij_cite_ethnicity_10$ij_same_ethnic [is.na(ij_cite_ethnicity_10$ij_same_ethnic )]<-0
### focus on ethnicity of last authors, as last author is the PI dominate this paper.  
ij_cite_ethnicity_10$last_author<-ifelse(ij_cite_ethnicity_10$names_count==ij_cite_ethnicity_10$seq_no,1,0)
ij_cite_ethnicity_10$first_author<-ifelse(ij_cite_ethnicity_10$seq_no==1,1,0)
ij_cite_ethnicity_10$lastorfirst_author<-ifelse(ij_cite_ethnicity_10$last_author==1|ij_cite_ethnicity_10$first_author,1,0)
### use the max prob as the name orign country 
ij_cite_ethnicity_10$value[is.na(ij_cite_ethnicity_10$value)]<-0
ij_cite_ethnicity_10<-ij_cite_ethnicity_10%>%group_by(last_name)%>%mutate(max_v = max(value))
ij_cite_ethnicity_10$max_like_code<-ifelse(ij_cite_ethnicity_10$value==ij_cite_ethnicity_10$max_v,1,0)
ij_cite_ethnicity_10$max_like_code[is.na(ij_cite_ethnicity_10$max_like_code)]<-0


ij_cite_ethnicity_10$sameth_max_last<-ij_cite_ethnicity_10$max_like_code*ij_cite_ethnicity_10$ij_same_ethnic * ij_cite_ethnicity_10$last_author

ij_cite_ethnicity_10_final<-ij_cite_ethnicity_10%>%group_by(pmid,rltd_pmid)%>%summarise(sameth_max_last=max(sameth_max_last))

matched_papers_obs<-matched_papers_obs%>%left_join(ij_cite_ethnicity_10_final, by = c( "pmid", "rltd_pmid"))

