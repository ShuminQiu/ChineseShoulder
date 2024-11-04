country_effect_plot <- read_excel("Country_effect_plot.xlsx")

country_effect_plot$country_effect_h_sd<-as.numeric(country_effect_plot$country_effect_h_sd)
country_effect_plot$country_effect_l_sd<-as.numeric(country_effect_plot$country_effect_l_sd)
country_effect_plot$country_effect_sd<-as.numeric(country_effect_plot$country_effect_sd)
country_effect_plot$treated_articles<-as.numeric(country_effect_plot$treated_articles)

bin_label_desc <- country_effect_plot %>%
  arrange(desc(country_effect_sd))%>% .$bin_label
country_effect_plot$bin_label <- factor(country_effect_plot$bin_label,levels= bin_label_desc)

library(ggplot2)
p15 <- ggplot(data = country_effect_plot%>% arrange(desc(country_effect_plot$country_effect_sd )),
              aes(x = bin_label, y = country_effect_sd)) + 
  geom_point() + 
  theme_classic()+theme_bw()+
  geom_hline(yintercept = 0, linetype = 2,color = 'black' ) + 
  # geom_errorbar(aes(ymin=country_effect_l_sd, ymax=country_effect_h_sd),width = 0.2, color = c('black','black','darkred') ) + 
  # geom_pointrange(aes(ymin=country_effect_l_sd, ymax=country_effect_h_sd),fatten = 6, color = c('black','black','darkred') )+
  geom_errorbar(aes(ymin=country_effect_l_sd, ymax=country_effect_h_sd),width = 0.2, color = 'black') + 
  geom_pointrange(aes(ymin=country_effect_l_sd, ymax=country_effect_h_sd),fatten = 6, color = 'black')+
  # geom_point(aes(shape = hc_country)) +
  lims( y = c(-0.2,0.2))+
  labs(x = '', y = 'Country effect in s.d. units',family="STKaiti", face = 'bold') +
  geom_text(aes(x = bin_label, y = country_effect_h_sd + 0.02 , label = paste0 ('N = ', comma(treated_articles))) , size = 7,color = 'black',fontface ='bold' )+
  theme(text=element_text(face = 'bold', color = 'black', size = 20),
        plot.title=element_text(hjust = 0.5),
        axis.text.y =  element_text(size = rel(1.5), face = 'bold', color = 'black'), 
        axis.text.x = element_text(size = rel(1.5), hjust = 1,color = 'black', angle = 30),
        legend.position='none') 

print(p15)
