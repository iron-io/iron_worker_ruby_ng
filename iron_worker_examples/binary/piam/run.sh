export LD_LIBRARY_PATH=/task/gsl/lib

echo "-------- Running PIAM_single -----------"
./PIAM_single
echo "--------- Finished running PIAM_single ----------\n\n"



echo "---------- Running PIAM -----------"
./PIAM
echo "--------- Finished running PIAM ----------\n\n"

echo "Results output:\n\n"

cat PIAM_result/example.txt_example.txt.txt

