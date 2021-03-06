# Load
vendas <- read.csv("vendas.csv", sep=";", dec=",")
names(vendas) <- c('date', 'month', 'weekday', 'margin', 'sales', 'discount', 'outdisc', 'outmg')

# Teste de consist�ncia dos dados
any(is.na(vendas))
sum(is.na(vendas))
colSums(is.na(vendas))

# Tratamento dos caracteres quebrados

library(dplyr)
#vendas %>%
#  select (weekday) %>%
#  distinct

vendas$date <- as.factor(vendas$date)

vendas$weekday <- factor(vendas$weekday,
                         levels= c("domingo", 
                                   "segunda-feira", 
                                   "ter?a-feira", 
                                   "quarta-feira", 
                                   "quinta-feira", 
                                   "sexta-feira", 
                                   "s?bado"),
                         labels = c(1,2,3,4,5,6,7))
vendas$month <- factor(vendas$month,
                         levels= c("janeiro", "fevereiro", "mar?o", "abril", "maio", 
                                   "junho", "julho", "agosto", "setembro", "outubro",
                                   "novembro", "dezembro"),
                         labels = c(1,2,3,4,5,6,7,8,9,10,11,12))

# Trocando o tipo para INT
vendas$weekday <- as.numeric(vendas$weekday)
vendas$month <- as.numeric(vendas$month)

# Correlações
cor(vendas)
summary(vendas)

install.packages("ggplot2")
library(ggplot2)

#boxplot(vendas)

#plot(vendas$sales~vendas$date, col=vendas$month)
#plot(vendas$sales~vendas$month)
#plot(vendas$sales~vendas$weekday)
#plot(vendas$sales~vendas$margin)
#plot(vendas$sales~vendas$discount)

#hist(vendas$sales)
#hist(vendas$margin)
#hist(vendas$discount)

# Tirando outliers
install.packages("plyr")
library(plyr)
vendas <- vendas[vendas$outmg==0,]
vendas <- vendas[vendas$outdisc==0,]


# Separando bases de Treino e Teste
#set.seed(33)
#v <- sample(nrow(vendas))
treino <- vendas[1:365,]
teste <- vendas[366:396,]

# Regressão Linear
mod <- lm(sales~month+weekday+discount, data=treino)
summary(mod)


# Modelo Autoregressivo
install.packages("dummies")
library(dummies)
# Append dummies in vendas
vendasAR <- vendas
vendasAR <- cbind(vendasAR, dummy(vendasAR$month))
#Gerando nova base de treino
treinoAR <- vendasAR[1:365,]
testeAR <- vendasAR[366:396,]

mAR <- lm(sales~vendasAR8 +  vendasAR9 + vendasAR11 + vendasAR10 + weekday + margin + discount, data=treinoAR)
summary(mAR)


# Arvore de decisão
install.packages("party")
library(party)

mTree <- ctree(sales~vendasAR8 +  vendasAR9 + vendasAR11 + vendasAR10 + weekday + margin + discount, data=treinoAR)
summary(mTree)
plot(mTree, type="simple") #analizar entropia

# Random Forest

install.packages('caret')
library("caret")
mRF <- randomForest(sales~vendasAR8 +  vendasAR9 + vendasAR11 + vendasAR10 + weekday + margin + discount, data=treinoAR)
p <- predict(mRF, newdata=testeAR)
#Confusion Matrix
#table(p, teste$sales)
cm <- confusionMatrix(testeAR$sales, p)
#str(cm)
overall <- cm$overall
overall['Accuracy'] 

# SVM



# SUBMISSAO PARA KAGGLE
p <- predict(mAR, newdata=testeAR)
svf <- as.data.frame(row.names(testeAR))
svf$venda <-p
# Nomes das colunas
names(svf) <- c("Id", "Expected")
# Gravaçãoo em disco do arquivo a ser submetido no site Kaggle
write.csv(svf, file="submit2.csv", row.names = FALSE)
