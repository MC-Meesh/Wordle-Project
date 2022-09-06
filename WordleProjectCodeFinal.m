
clc; clear;  close all;

%% Part 1 - Plotting WWF and MW Dictionaries
WWF = fopen("words.txt");
WWF_Dict = textscan(WWF,'%s');    %Opens and scans WWF Dictionary
fclose(WWF);

WWF_Dict = WWF_Dict{1, 1};  %Defines the WWF Dictionary as  readable data

WWF_Distribution =  zeros(1,20);  %Initalize vector

for i = 1:numel(WWF_Dict)                   %Loop through each word
    str_length = strlength(WWF_Dict(i));
    if str_length > 20
        continue                                %Skip if word is longer than 20 letters 
    end 
    WWF_Distribution(str_length) = WWF_Distribution(str_length) + 1;  %Add 1 for corresponding category
end

figure('Name', 'Word Length Distribution')  %initalize first figure
hold on
scatter(1:20,WWF_Distribution, 'o', 'black')  %Plot WWF data


MW = fopen("webster-dictionary.txt");
MW_Dict = textscan(MW,'%s', 'Delimiter', '\n');            %Open and scan Merriam Web. 
fclose(MW);

MW_Dict = MW_Dict{1, 1};    %Define MW Dictionary

MW_Distribution =  zeros(1,20);  %Initalize MW vector

for i = 1:numel(MW_Dict)                   %Loop through each word
    str_length = strlength(MW_Dict(i));
    if str_length > 20
        continue                                %Skip if word is longer than 20 letters 
    end 
    MW_Distribution(str_length) = MW_Distribution(str_length) + 1;  %Add 1 for corresponding category
end

scatter(1:20,MW_Distribution, 'o', 'r')  %Plot MW data
title('Word Distribution')
xlim([1 20])
xlabel('Word Length')
ylabel('Number of Words')
legend('Words With Friends','Merriam-Webster Dictionary')
hold off


Five_Letter_Words = WWF_Dict(strlength(WWF_Dict)  == 5);  %Find all words of length 5 in the WWF Dictionary

%% Part 2 - Analyze the letter frequency in the word list

az_scores = [];

for j = 3:2:9 %loop through each length of word

    N = j;
    N_Letter_Words = WWF_Dict(strlength(WWF_Dict)  == N);  %Find all words of length N in the WWF Dictionary
    
    if N == 9
        N_Letter_Words = WWF_Dict; 
    end


    az_distribution = zeros(1, 26); %initalize letter distribution and alphabet vector 
    az =  'a':'z';
    
    for i = 1:numel(N_Letter_Words)
        for j = 1:26
            if contains(N_Letter_Words(i),az(j)) == true
                count = numel(find(az(j)==char(N_Letter_Words(i))));
                az_distribution(j) = az_distribution(j) + count;
            end
        end
    end
    
    az_distribution = az_distribution / sum(az_distribution); %convert distribution to percentage
    az_scores = cat(1, az_scores,az_distribution);            %save scores of each discribution for section 3


    figure('Name', sprintf('Letter Distribution %d Letter Words', N)) %initalize additional figure. NOTE - '9 letter words' is actually ALL WORDS in WWF Dict (titled  9 given loop for each figure)
    hold on
    
    %title(sprintf('Letter Distribution %d Letter Words', N)) 
    if N ~= 9
        title(sprintf('Letter Distribution %d Letter Words', N)) 
    else
        title('Letter Distribution for All Words')
    end
    
    bar(categorical(num2cell(az)),az_distribution)
    ylabel('% Frequency')
    xlabel('Letter')

    hold off
end

%% Part 3 - Best Starting Word
% _%Starting by defining all 5 letter unique words_ 

norepeats = zeros(1, numel(WWF_Dict)); %initalize no repeat vector

for i = 1:numel(WWF_Dict) %loop through each word in WWF dictionary

    for j = 1:26                            %Loop through each letter
        if numel(find(az(j)==char(WWF_Dict(i)))) >= 2   %If a letter appears more than  once, define repeat to be true and break out of alphabet loop
            repeat = true;
            break
        else 
            repeat = false;
        end
    end

    if repeat == false                   %If there were no repeated letters, define norepeats as true - otherwise define element as 0 (there was a repeat)
        norepeats(i) =  true;
    else
        norepeats(i) =  false;
    end

end

norepeats = logical(norepeats);     %convert to logical array
norepeats = WWF_Dict(norepeats);    %index for all non-repeated (true) cases
Best_Five_Letter_Words = norepeats(strlength(norepeats)  == 5); %Reduce List to only 5 letter words

% _%Scoring Each Word_ 

word_score = zeros(1, numel(Best_Five_Letter_Words));
five_letter_scores = az_scores(2,:);

for i = 1:numel(Best_Five_Letter_Words)     %scoring words
    sum = 0;

    for j = 1:26
        if contains(Best_Five_Letter_Words(i), az(j)) == true   %if a word i contains a letter, the corresponding score is added to the sum
            sum = sum + five_letter_scores(j);
        end
    end
    word_score(i) = sum;        %sum is assigned to coresponding word i
end


[word_score_sorted, idx] = (sort(word_score, 'descend')); %sort scores and note assocaited index
Best_Five_Letter_Words = Best_Five_Letter_Words(idx); %arrange to best words based on sorted index
top_20_words = Best_Five_Letter_Words(1:20) %DISPLAY top 20 best  words


%% Part 4 - Wordle
Five_Letter_Words = string(Five_Letter_Words);  %format so that WWF Dict is 5 letters (not characters or cell or whatever)
word = Five_Letter_Words(randi(numel(Five_Letter_Words)));  %Define word to be guessed (correct answer), UNSUPRESS to run with known answer for testing
attempt = 0;        %initalize starting attempt
guess_log = [];     %initalize guess log 

while attempt ~= 6  %Wordle game logic
    attempt  = attempt + 1;
    check = false;

    while check == false    %take 5 letter user input (guess)
        check = false;
        guess = lower(string(input('Enter a guess\n', 's')));       %Take user guess
        
        if any(strcmp(Five_Letter_Words, guess)) %check that word is valid from WWF Dict. (length 5, characters, etc.)
            check = true;
        else
            warning('Please enter a valid 5 letter word')
        end
    end

    guess = char(guess);    %convert strings to characters for indexing
    word = char(word);

    matched_characters = zeros(1,5);      %initalize matching letters, could be done using logical arrays but I got tired
    characters_in_word = [];      %initalize correct characters in guess
    missing_characters = [];     %initalize characters that are known to not be in the word
   
    
    for i = 1:5     %parse for correct letter placement and use
        if contains(word, guess(i))==false
            missing_characters = [missing_characters upper(guess(i))];
        elseif word(i) == guess(i)
            matched_characters(i) = true;
        else
            characters_in_word  = [characters_in_word guess(i)];
        end
    end


    known_word = [];
    for i = 1:5        %format display for user to see correct letter guesses
        if i ==1 && matched_characters(i) == 1
            known_word = [known_word upper(guess(i))];
        elseif matched_characters(i) == 1
            known_word = [known_word ' ' upper(guess(i))];
        else
            known_word = [known_word ' ' '*'];
        end
    end
    
    guess_log = [guess_log; string(known_word)]; %store guesses to display at end

    if guess == word    %check that 
        break
    end

    fprintf('\nFrom %s, you got the follwoing correct\n',upper(guess))      %display disclosed letters and useful information
    disp(known_word)

    fprintf('\nThe following characters are also in the word, but not the correct place:\n')
    disp(upper(characters_in_word))

    fprintf('\nThe following characters are not in the word:\n')
    disp(missing_characters)
    
    if attempt ~= 6
        fprintf('\n---------------ATTEMPT %i--------------------\n', (attempt+1))
    end

end


%display end results
if guess == word    %win condition
    fprintf('\nCongrats, you guessed %s in %i attempt(s)\n', upper(word), attempt)
    disp(guess_log(:))
else                %loss condition
    fprintf("\nSorry, looks like you're out of attempts. The word was %s\n", upper(word))
    disp(guess_log(:))
end

fprintf('\nThanks for playing \n  ~Michael Allen, 2022\n')