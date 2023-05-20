# github submodule repo addresses without https:// prefix
declare -A remotes=(
    ["submodule1"]="github.com/abhishekintern/submodule1"
    ["submodule2"]="github.com/abhishekintern/submodule2"
)

# github access token is necessary
# add it to Environment Variables on Vercel
if [ "$GITHUB_ACCESS_TOKEN" == "" ]; then
   echo "Error: GITHUB_ACCESS_TOKEN is empty"
   exit 1
fi

# stop execution on error - don't let it build if something goes wrong
set -e

# get submodule commit
output=`git submodule status --recursive` # get submodule info

# Extract each submodule commit hash and path
submodules=$(echo $output | sed "s/ -/_/g" | sed "s/ /=/g" | sed "s/-//g" | sed 's/([^)]*)//g' | tr "_" "\n")

for submodule in $submodules; do
    IFS="=" read COMMIT SUBMODULE_PATH <<<"$submodule"

    SUBMODULE_GITHUB=$remotes[$SUBMODULE_PATH]
    
    echo $SUBMODULE_PATH
    # set up an empty temporary work directory
    rm -rf tmp || true # remove the tmp folder if exists
    mkdir tmp          # create the tmp folder
    cd tmp             # go into the tmp folder

    # checkout the current submodule commit
    git init                                                                      # initialise empty repo
    git remote add $SUBMODULE_PATH https://$GITHUB_ACCESS_TOKEN@$SUBMODULE_GITHUB # add origin of the submodule
    git fetch --depth=1 $SUBMODULE_PATH $COMMIT                                   # fetch only the required version
    git checkout $COMMIT                                                          # checkout on the right commit

    # move the submodule from tmp to the submodule path
    cd ..                     # go folder up
    rm -rf tmp/.git           # remove .git
    mv tmp/* $SUBMODULE_PATH/ # move the submodule to the submodule path

    # clean up
    rm -rf tmp # remove the tmp folder
done