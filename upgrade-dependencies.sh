#!/usr/bin/env bash

if [ "$1" == "" ] || [ "$1" == "--help" ]; then
  echo "Available flags:"
  echo "--help"
  echo "--upgrade-expo - run yarn to add latest Expo and npx expo install --fix upgrade to update to latest SDK on all examples"
  echo "--fix-dependencies - run npx expo install --fix on all repos"
  exit 0
fi

manager="${EXPO_PACKAGE_MANAGER:-yarn}"

if [ "$1" == "--upgrade-expo" ]; then
  echo "Upgrading all projects to the latest SDK..."
  echo "For each example, this will run `yarn` to add latest Expo and then run `npx expo install --fix`, accepting all defaults."
  echo "Upgrade logs will be written to .sdk-upgrade-logs."

  mkdir -p ./.sdk-upgrade-logs
  for d in */ ; do
    DIRNAME=${d%/}
    echo "Upgrading $DIRNAME..."
    echo "• Run $manager install"
    (cd $DIRNAME && $manager install --ignore-scripts &> ../.sdk-upgrade-logs/$DIRNAME-install.txt || echo "FAILURE") # If yarn fails spectacularly, we'll see evidence in the logs for expo upgrade
    echo "• Run expo upgrade"
    (cd $DIRNAME && $manager add expo@latest && $manager expo install --fix &> ../.sdk-upgrade-logs/$DIRNAME-upgrade.txt || echo "FAILURE")
  done

  # yarn workspaces has example(s) inside of app folder
  echo "• Run expo upgrade on apps inside with-yarn-workspaces"
  mkdir -p ./.sdk-upgrade-logs/with-yarn-workspaces
  for d in  with-yarn-workspaces/apps/*/ ; do
    echo "• Run yarn install"
    (cd $DIRNAME && yarn install &> ../.sdk-upgrade-logs/with-yarn-workspaces/$DIRNAME-install.txt || echo "FAILURE")
    echo "• Run expo upgrade"
    (cd $DIRNAME && yarn add expo@latest && yarn expo install --fix &> ../.sdk-upgrade-logs/with-yarn-workspaces/$DIRNAME-upgrade.txt)
  done

  echo "Upgrades complete! Check .sdk-upgrade-logs for results. Be sure to correct any errors or warnings."
  echo "WARNING: with-dev-client has native project files that need to be upgraded manually!"
  echo "Deleting ios/android folders and running prebuild will regenerate them, applying the proper URL schemes."
  echo "https://docs.expo.dev/development/installation/ has more info on how a bare dev client project is setup."
  exit 0
fi

if [ "$1" == "--fix-dependencies" ]; then
  echo "Fixing dependencies on all examples..."

  mkdir -p ./.sdk-fix-logs
  for d in */ ; do
    DIRNAME=${d%/}
    echo "Fixing dependencies on $DIRNAME..."
    echo "• Run $manager install"
    (cd $DIRNAME && $manager install --ignore-scripts &> ../.sdk-fix-logs/$DIRNAME-install.txt || echo "FAILURE") # If yarn fails spectacularly, we'll see evidence in the logs for expo upgrade
    echo "• Run expo fix"
    (cd $DIRNAME && $manager expo install --fix &> ../.sdk-fix-logs/$DIRNAME-fix.txt)
  done

  echo "Fixing dependencies on apps inside with-yarn-workspaces..."
  mkdir -p ./.sdk-fix-logs/with-yarn-workspaces
  for d in  with-yarn-workspaces/apps/*/ ; do
    echo "• Fixing dependencies on apps inside with-yarn-workspaces"
    echo "• Run yarn install"
    (cd $DIRNAME && yarn install &> ../.sdk-fix-logs/with-yarn-workspaces/$DIRNAME-install.txt || echo "FAILURE") # If yarn fails spectacularly, we'll see evidence in the logs for expo upgrade
    echo "• Run expo fix"
    (cd $DIRNAME && yarn expo install --fix &> ../.sdk-fix-logs/with-yarn-workspaces/$DIRNAME-fix.txt || echo "FAILURE")

  done

  echo "Dependency fixes complete!"
  exit 0
fi

echo "Error: flag not recognized"
