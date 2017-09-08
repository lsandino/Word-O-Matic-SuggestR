katzBOProb <- function (strInput, n = 3){
    
    d <- 0.75
    
    table4 <- tetragrams %>% 
        filter(word1 == strInput$words[1] & word2 == strInput$words[2] & word3 == strInput$words[3]) %>%
        rename(r = n)
    if (nrow(table4) > 0){
        data4 <- count(table4, r, sort = T)
        if (nrow(data4) >= 5){
            table4 <- tryCatch({
                fit4 <- nlsLM(n ~ A*r^(-B), start = list(A = 1000, B = 1), data = data4)
                mutate(table4, `r*` = (r + 1)*predict(fit4, list(r = r + 1))/predict(fit4, list(r = r)))
            },
            error = function(cond){
                return(mutate(table4, `r*` = r - d))
            },
            warning = function(cond){
                
            },
            finally = {}
            )
        } else{
            table4 <- mutate(table4, `r*` = r - d)
        }
        table4 <- mutate(table4, P = `r*`/sum(r))
        alpha3 <- 1 - sum(table4$`r*`/sum(table4$r))
    } else{
        table4 <- mutate(table4, P = r)
        alpha3 <- 1
    }
    
    table3 <- trigrams %>% 
        filter(word1 == strInput$words[2] & word2 == strInput$words[3]) %>%
        rename(r = n)
    if (nrow(table3) > 0){
        data3 <- count(table3, r, sort = T)
        table3 <- table3 %>% 
            filter(word3 %in% c(setdiff(table4$word4, table3$word3), setdiff(table3$word3, table4$word4)))
        if (nrow(data3) >= 5){
            table3 <- tryCatch({
                fit3 <- nlsLM(n ~ A*r^(-B), start = list(A = 1000, B = 1), data = data3)
                mutate(table3, `r*` = (r + 1)*predict(fit3, list(r = r + 1))/predict(fit3, list(r = r)))
            },
            error = function(cond){
                return(mutate(table3, `r*` = r - d))
            },
            warning = function(cond){
                
            },
            finally = {}
            )
        } else{
            table3 <- mutate(table3, `r*` = r - d)
        }
        table3 <- mutate(table3, P = alpha3*`r*`/sum(r))
        alpha2 <- 1 - sum(table3$`r*`/sum(table3$r))
    } else{
        table3 <- mutate(table3, P = r)
        alpha2 <- 1
    }
    
    table2 <- bigrams %>% 
        filter(word1 == strInput$words[3]) %>%
        rename(r = n)
    if (nrow(table2) > 0){
        data2 <- count(table2, r, sort = T)
        table2 <- table2 %>% 
            filter(word2 %in% c(setdiff(c(table4$word4, table3$word3), table2$word2), setdiff(table2$word2, c(table4$word4, table3$word3))))
        if (nrow(data2) >= 5){
            table2 <- tryCatch({
                fit2 <- nlsLM(n ~ A*r^(-B), start = list(A = 1000, B = 1), data = data2)
                mutate(table2, `r*` = (r + 1)*predict(fit2, list(r = r + 1))/predict(fit2, list(r = r)))
            },
            error = function(cond){
                return(mutate(table2, `r*` = r - d))
            },
            warning = function(cond){
                
            },
            finally = {}
            )
        } else{
            table2 <- mutate(table2, `r*` = r - d)
        }
        table2 <- mutate(table2, P = alpha2*alpha3*`r*`/sum(r))
        alpha1 <- 1 - sum(table2$`r*`/sum(table2$r))
    } else{
        table2 <- mutate(table2, P = r)
        alpha1 <- 1
    }
    
    table1 <- unigrams %>% 
        filter(words %in% c(setdiff(c(table4$word4, table3$word3, table2$word2), unigrams$words), setdiff(unigrams$words, c(table4$word4, table3$word3, table2$word2)))) %>%
        rename(r = n) %>%
        mutate(P = alpha1*alpha2*alpha3*r/sum(r))
    
    final <- arrange(bind_rows(rename(select(table4, word4, P), Suggestion = word4), rename(select(table3, word3, P), Suggestion = word3), rename(select(table2, word2, P), Suggestion = word2), rename(select(table1, words, P), Suggestion = words)), desc(P)) 
    final <- final %>%
        mutate(`P (%)` = round(100*P, 2), `Text input` = paste(strInput$words[1], strInput$words[2], strInput$words[3]), sep = " ") %>%
        select(`Text input`, Suggestion, `P (%)`)
    
    katzBOProb <- head(final, n)
}
