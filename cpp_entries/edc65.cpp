#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <ctime>
#include <cstdlib>

using namespace std;

class LRTimer
{
private:
    time_t start;
public:
    void startTimer(void)
    {
        time(&start);
    }

    double stopTimer(void)
    {
        return difftime(time(NULL),start);
    } 

};

#define MAX_WORD_LEN 15
#define BIT_QM 0x8000

LRTimer timer;
int size, valid, wordLen;

string firstGuess[] = { "", "a", "as", "iao", "ares", 
    "raise", "sailer", "saltier", "costlier", "clarities", 
    "anthelices", "petulancies", "incarcerates", "allergenicity" };

class Pattern
{
public:
    char letters[MAX_WORD_LEN];
    char flag;
    int mask;

    Pattern() 
        : letters(), mask(), flag()
    {
    }

    Pattern(string word) 
        : letters(), mask(), flag()
    {
        init(word);
    }

    void init(string word)
    {
        const char *wdata = word.data();
        for(int i = 0; i < wordLen; i++) {
            letters[i] = wdata[i];
            mask |= 1 << (wdata[i]-'a');
        }
    }

    string dump()
    {
        return string(letters);
    }

    int check(Pattern &secret)
    {
        if ((mask & secret.mask) == 0)
            return 0;

        char g[MAX_WORD_LEN], s[MAX_WORD_LEN];
        int r = 0, q = 0, i, j, k=99;
        for (i = 0; i < wordLen; i++)
        {
            g[i] = (letters[i] ^ secret.letters[i]);
            if (g[i])
            {
                r += r;
                k = 0;
                g[i] ^= s[i] = secret.letters[i];
            }
            else
            {
                r += r + 1;
                s[i] = 0;
            }
        }
        for (; k < wordLen; k++)
        {
            q += q;
            if (g[k]) 
            {
                for (j = 0; j < wordLen; j++)
                    if (g[k] == s[j])
                    {
                        q |= BIT_QM;
                        s[j] = 0;
                        break;
                    }
            }
        }
        return r|q;
    }

    int count(int ck, int limit);

    int propcheck(int limit);

    void filter(int ck);
};

string dumpScore(int ck)
{
    string result(wordLen, 'X');
    for (int i = wordLen; i--;)
    {
        result[i] = ck & 1 ? 'O' : ck & BIT_QM ? '?' : 'X';
        ck >>= 1;
    }
    return result;
}

int parseScore(string ck)
{
    int result = 0;
    for (int i = 0; i < wordLen; i++)
    {
        result += result + (
            ck[i] == 'O' ? 1 : ck[i] == '?' ? BIT_QM: 0
        );
    }
    return result;
}

Pattern space[100000];

void Pattern::filter(int ck)
{
    int limit = valid, i = limit;
//  cerr << "Filter IN Valid " << setbase(10) << valid << " This " << dump() << "\n"; 

    while (i--)
    {
        int cck = check(space[i]);
//      cerr << setbase(10) << setw(8) << i << ' ' << space[i].dump() 
//          << setbase(16) << setw(8) << cck << " (" << Pattern::dumpScore(cck) << ") ";

        if ( ck != cck )
        {
//          cerr << " FAIL\r" ;
            --limit;
            if (i != limit) 
            {
                Pattern t = space[i];
                space[i] = space[limit];
                space[limit] = t;
            }
        }
        else
        {
//          cerr << " PASS\n" ;
        }
    }
    valid = limit;
//  cerr << "\nFilter EX Valid " << setbase(10) << valid << "\n"; 
};

int Pattern::count(int ck, int limit)
{
    int i, num=0;
    for (i = 0; i < valid; ++i)
    {
        if (ck == check(space[i]))
            if (++num >= limit) return num;
    }
    return num;
}

int Pattern::propcheck(int limit)
{
    int k, mv, nv;

    for (k = mv = 0; k < valid; ++k)
    {
        int ck = check(space[k]);
        nv = count(ck, limit);
        if (nv >= limit)
        {
            return 99999;
        }
        if (nv > mv) mv = nv;
    }
    return mv;
}

int proposal(bool last)
{
    int i, minnv = 999999, mv, result;

    for (i = 0; i < valid; i++) 
    {
        Pattern& guess = space[i];
//      cerr << '\r' << setw(6) << i << ' ' << guess.dump();
        if ((mv = guess.propcheck(minnv)) < minnv)
        {
//          cerr << setw(6) << mv << ' ' << setw(7) << setiosflags(ios::fixed) << setprecision(0) << timer.stopTimer() << " s\n";
            minnv = mv;
            result = i;
        }
    }   
    if (last) 
        return result;
    minnv *= 0.75;
    for (; i<size; i++) 
    {
        Pattern& guess = space[i];
//      cerr << '\r' << setw(6) << i << ' ' << guess.dump();
        if ((mv = guess.propcheck(minnv)) < minnv)
        {
//          cerr << setw(6) << mv << ' ' << setw(7) << setiosflags(ios::fixed) << setprecision(0) << timer.stopTimer() << " s\n";
            minnv = mv;
            result = i;
        }
    }   
    return result;
}

void setup(string wordfile)
{
    int i = 0; 
    string word;
    ifstream infile(wordfile.data());
    while(infile >> word)
    {
        if (word.length() == wordLen) {
            space[i++].init(word);
        }
    }
    infile.close(); 
    size = valid = i;
}

int main(int argc, char* argv[])
{
    if (argc < 2) 
    {
        cerr << "Specify word length";
        return 1;
    }

    wordLen = atoi(argv[1]);

    timer.startTimer();
    setup("wordlist.txt");
    //cerr << "Words " << size 
    //  << setiosflags(ios::fixed) << setprecision(2)
    //  << " " << timer.stopTimer() << " s\n";

    valid = size;
    Pattern Guess = firstGuess[wordLen];
    for (int t = 0; t < 5; t++)
    {
        cout << Guess.dump() << '\n' << flush;
        string score;
        cin >> score;
        int ck = parseScore(score);
        //cerr << "\nV" << setw(8) << valid << " #" 
        //  << setw(3) << t << " : " << Guess.dump()
        //  << " : " << score << "\n";
        if (ck == ~(-1 << wordLen))
        {
            break;
        }
        Guess.filter(ck); 
        Guess = space[proposal(t == 3)];
    }
    cerr << "\n";

    double time = timer.stopTimer();
    //cerr << setiosflags(ios::fixed) << setprecision(2)
    //   << timer.stopTimer() << " s\n";

    return 0;
}
