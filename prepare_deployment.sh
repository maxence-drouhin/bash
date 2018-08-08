
#!/bin/bash
#author: maxence.drouhin@gmail.com
#use: ./tarball.sh <only-build>
#parameter only-build is optional and useful to rebuild the final package

###############
#  VARIABLES  #
###############

export COMMIT_DIFF_LIST
COMMIT_DIFF_LIST[0]="7b48d27 6b7ea02"


export GIT_PROJECT="test"


export EXCLUDE_PATTERN="^((autoload|build)/.*)|(build.*)$"

###############
# /VARIABLES  #
###############

function build
{
    # Increment version build in file
    VERSION=`cat version | sed 's,^ *,,; s, *$,,' | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`
    echo $VERSION > version

    tar czvf livraison.tar.gz source.tar.gz version custom_install.sh sql/

    cp -f livraison.tar.gz ../

    echo "Tarball for release $VERSION successfully build"
}

function tarball
{
    if [ -d ~/git ]; then
        GIT_DIRECTORY=~/git
    else
        GIT_DIRECTORY=/c/git
    fi

    CORAIL_DIRECTORY=`pwd`

    cd $GIT_DIRECTORY/$GIT_PROJECT
    if [ ! -d "$GIT_DIRECTORY/$GIT_PROJECT" ]; then
        exit 1
    fi

    rm -f livraison.txt
    for COMMIT_DIFF_LINE in "${COMMIT_DIFF_LIST[@]}"
    do
        git diff-tree --no-commit-id --name-only --diff-filter=AM -r $COMMIT_DIFF_LINE | grep -v -E $EXCLUDE_PATTERN >> livraison.txt
    done
    cat livraison.txt | sort | uniq > livraison.txt
    tar czvf ../source.tar.gz -T livraison.txt
    rm livraison.txt

    cd "$CORAIL_DIRECTORY"
    rm -f source.tar.gz
    cp -fv $GIT_DIRECTORY/source.tar.gz .
    rm -f $GIT_DIRECTORY/source.tar.gz

    echo -e "\nLaunch build package ?"
    read -n1 -r -p "[yes/oui] : " response
    if [ "$response" = 'y' ] || [ "$response" = 'o' ]; then
        echo -e "\n"
        build
    fi
}

if [[ "$1" == "only-build" ]]
then
    build
else
    tarball
fi