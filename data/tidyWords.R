tidyWords <- function (strInput, n = 0){
    
    strInput <- as.character(strInput)
    
    #Remove e-mails:
    regex <- "\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\\b"
    if (stri_count_regex(strInput, regex) > 0){
        strInputt <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    #Remove URLs (starting in http or www):
    regex <- "((http|HTTP)[\\S]+)|((www|WWW)\\.[\\S]+)"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    #Remove URLs (written without http or www). Most common domain extensions are used:
    regex <- "[\\S]*\\.(com|org|edu|gov|net|biz|gl|ly|COM|ORG|EDU|GOV|NET|BIZ|GL|LY)(?![a-zA-Z])[/]?[\\S]*"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    #Turn single @ into "at":
    regex <- "@\\s"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "at ")
    }
    
    #Remove user names (@username):
    regex <- "@[\\S]+"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ") 
    }
    
    #Fix word1.word2 errors
    regex <- "\\.([a-zA-Z]{2,})"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "\\. $1")
    }
    
    #Turn more than 2 consecutive dots into a full stop:
    regex <- "\\.[\\.]{1,}"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "\\. ")
    }
    
    #Turn ellipsis dots character into a space:
    regex <- "\u2026"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    #Remove dot after abbreviations (like a.m., U.S., etc.):
    regex <- "(?<!\\w|')([a-zA-Z])\\."
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "$1")
    }
    
    #Remove dot after abbreviations (like Dr., Mr., St., etc.):
    regex <- "\\s(Mr|Ms|Dr|St|Ps|mr|ms|dr|st|ps)\\."
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " $1")
    }
    
    #Turn colon into a full stop:
    regex <- ":"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "\\. ")
    }
    
    #Remove numbers
    regex <- "[0-9]+"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "")
    }
    
    #To lowercase
    striInput <- tolower(strInput)
    
    #Load contractions dictionary:
    contractions <- get(data(contractions))
    contractions <- transmute(contractions, contraction = tolower(contraction), expanded = tolower(expanded))
    contractions <- rbind(contractions, c("y'all", "you all"))
    contractions <- rbind(contractions, c("here's", "here is"))
    contractions <- rbind(contractions, c("haven't", "have not"))
    contractions <- rbind(contractions, c("hadn't", "had not"))
    
    #Turn curly left/right single/double quotation marks and acute accent characters into regular ones: 
    regex <- "\u2018|\u2019|\u00B4"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "'")
    }
    regex <- "\u201C|\u201D"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "\"")
    }
    
    #Turn in' into ing
    regex <- "in'\\s"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, "ing ")
    }
    
    #Expand contraction using the dictionary:
    for (i in seq(1 : length(contractions$contraction))){
        if (stri_count_fixed(strInput, contractions$contraction[i]) > 0){
            strInput <- stri_replace_all_fixed(strInput, contractions$contraction[i], contractions$expanded[i])
        }
    }

    #Remove possessive ('s):
    regex <- "'s\\s"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    #Remove punctuation
    regex <- "[[:punct:]\\^\\$]"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    regex <- "\\u00F8"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    #Remove non-ASCII characters
    regex <- "[^[:ascii:]]"
    if (stri_count_regex(strInput, regex) > 0){
        strInput <- stri_replace_all_regex(strInput, regex, " ")
    }
    
    strInput <- data_frame(text = strInput)
    strInput <- unnest_tokens(strInput, words, text, token = "words")
    if (length(strInput$words) == 1){
        strInput <- data_frame(words = c("*", "*", strInput$words))
    } else if (length(strInput$words) == 2){
        strInput <- data_frame(words = c("*", strInput$words))
    }
        
    if (n == 0){
        tidyWords <- strInput
    } else{
        tidyWords <- tail(strInput, n)
    }
    
}