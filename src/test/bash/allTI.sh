
# Definir le repertoire contenant les fichiers de tests
TEST_DIR="../bash"

# Verifier si le repertoire existe
if [ ! -d "$TEST_DIR" ]; then
        echo "Le repertoire $TEST_DIR n'existe pas."
        exit 1
fi

# Executer tous les fichiers de tests dans le repertoire
for test_file in "$TEST_DIR"/TI_*.sh; do
        if [ -f "$test_file" ]; then
                bash "$test_file"
                if [ $? -ne 0 ]; then
                        echo "$test_file a echoue."
                        exit 1
                fi
        fi
done


