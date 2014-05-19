import java.util.*;
import java.io.*;

class Lingo{
    public static String[] guessBestList = new String[]{
                                "",
                                "a",
                                "sa",
                                "tea",
                                "orae",
                                "seora", // 5
                                "ariose",
                                "erasion",
                                "serotina",
                                "tensorial",
                                "psalterion", // 10
                                "ulcerations",
                                "culteranismo",
                                "persecutional"};
    public static HashMap<Integer, ArrayList<String>> wordlist = new HashMap<Integer, ArrayList<String>>();

    public static void main(String[] args){
        readWordlist("wordlist.txt");
        Scanner scanner = new Scanner(System.in);
        int wordlen = Integer.parseInt(args[0]);
        int roundNum = 5;
        ArrayList<String> candidates = new ArrayList<String>();
        candidates.addAll(wordlist.get(wordlen));
        String guess = "";
        while(roundNum-- > 0){
            guess = guessBest(candidates, roundNum==4, roundNum==0);
            System.out.println(guess);
            String response = scanner.nextLine();
            if(isAllO(response)){
                break;
            }
            updateCandidates(candidates, guess, response);
            //print(candidates);
        }
    }

    public static void print(ArrayList<String> candidates){
        for(String str: candidates){
            System.err.println(str);
        }
        System.err.println();
    }

    public static void readWordlist(String path){
        try{
            BufferedReader reader = new BufferedReader(new FileReader(path));
            while(reader.ready()){
                String word = reader.readLine();
                if(!wordlist.containsKey(word.length())){
                    wordlist.put(word.length(), new ArrayList<String>());
                }
                wordlist.get(word.length()).add(word);
            }
        } catch (Exception e){
            System.exit(1);
        }
    }

    public static boolean isAllO(String response){
        for(int i=0; i<response.length(); i++){
            if(response.charAt(i) != 'O') return false;
        }
        return true;
    }

    public static String getResponse(String word, String guess){
        char[] wordChar = word.toCharArray();
        char[] result = new char[word.length()];
        Arrays.fill(result, 'X');
        for(int i=0; i<guess.length(); i++){
            if(guess.charAt(i) == wordChar[i]){
                result[i] = 'O';
                wordChar[i] = '_';
            }
        }
        for(int i=0; i<guess.length(); i++){
            if(result[i] == 'O') continue;
            for(int j=0; j<wordChar.length; j++){
                if(result[j] == 'O') continue;
                if(wordChar[j] == guess.charAt(i)){
                    result[i] = '?';
                    wordChar[j] = '_';
                    break;
                }
            }
        }
        return String.valueOf(result);
    }

    public static void updateCandidates(ArrayList<String> candidates, String guess, String response){
        for(int i=candidates.size()-1; i>=0; i--){
            String candidate = candidates.get(i);
            if(!response.equals(getResponse(candidate, guess))){
                candidates.remove(i);
            }
        }
    }

    public static int countMatchingCandidates(ArrayList<String> candidates, String guess, String response){
        int result = 0;
        for(String candidate: candidates){
            if(response.equals(getResponse(candidate, guess))){
                result++;
            }
        }
        return result;
    }

    public static String[] getSample(ArrayList<String> words, int size){
        String[] result = new String[size];
        int[] indices = new int[words.size()];
        for(int i=0; i<words.size(); i++){
            indices[i] = i;
        }
        Random rand = new Random(System.currentTimeMillis());
        for(int i=0; i<size; i++){
            int take = rand.nextInt(indices.length-i);
            result[i] = words.get(indices[take]);
            indices[take] = indices[indices.length-i-1];
        }
        return result;
    }

    public static String guessBest(ArrayList<String> candidates, boolean firstGuess, boolean lastGuess){
        if(candidates.size() == 1){
            return candidates.get(0);
        }
        String minGuess = candidates.get(0);
        int wordlen = minGuess.length();
        if(firstGuess && guessBestList[wordlen].length()==wordlen){
            return guessBestList[wordlen];
        }
        int minMatches = Integer.MAX_VALUE;
        String[] words;
        if(lastGuess){
            words = candidates.toArray(new String[0]);
        } else if (candidates.size()>10){
            words = bestWords(wordlist.get(wordlen), candidates, 25);
        } else {
            words = wordlist.get(wordlen).toArray(new String[0]);
        }
        for(String guess: words){
            double sumMatches = 0;
            for(String word: candidates){
                int matches = countMatchingCandidates(candidates, guess, getResponse(word, guess));
                if(matches == 0) matches = candidates.size();
                sumMatches += (matches-1)*(matches-1);
            }
            if(sumMatches < minMatches){
                minGuess = guess;
                minMatches = sumMatches;
            }
        }
        return minGuess;
    }

    public static String[] bestWords(ArrayList<String> words, ArrayList<String> candidates, int size){
        int[] charCount = new int[123];
        for(String candidate: candidates){
            for(int i=0; i<candidate.length(); i++){
                charCount[(int)candidate.charAt(i)]++;
            }
        }
        String[] tmp = (String[])words.toArray(new String[0]);
        Arrays.sort(tmp, new WordComparator(charCount));
        String[] result = new String[size+Math.min(size, candidates.size())];
        String[] sampled = getSample(candidates, Math.min(size, candidates.size()));
        for(int i=0; i<size; i++){
            result[i] = tmp[tmp.length-i-1];
            if(i < sampled.length){
                result[size+i] = sampled[i];
            }
        }
        return result;
    }

    static class WordComparator implements Comparator<String>{
        int[] charCount = null;

        public WordComparator(int[] charCount){
            this.charCount = charCount;
        }

        public Integer count(String word){
            int result = 0;
            int[] multiplier = new int[charCount.length];
            Arrays.fill(multiplier, 1);
            for(char chr: word.toCharArray()){
                result += multiplier[(int)chr]*this.charCount[(int)chr];
                multiplier[(int)chr] = 0;
            }
            return Integer.valueOf(result);
        }

        public int compare(String s1, String s2){
            return count(s1).compareTo(count(s2));
        }
    }
}
