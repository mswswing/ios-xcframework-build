#!/usr/bin/env bash

iosxcframeworkbuild() {
	log() {
		local message=$1
		echo "iosxcframeworkbuild: "$message""
	}

	# Arguments


	outputdir=${outputdir:-.}

	while [ $# -gt 0 ]; do
		if [[ $1 == *"-"* ]]; then
			param="${1/-/}"
			declare $param="$2"
		fi
		shift
	done

	if [ -z "$project" ]; then
		log_error "error: Specify the project to use with the -project option."
		exit 0
	fi

	if [ -z "$scheme" ]; then
		log_error "error: Specify the project scheme to use with the -scheme option."
		exit 0
	fi

	if [ -z "$name" ]; then
		name="$scheme"
	fi

	# TEMP

	TEMP_DIR_PATH=.IOS_XCFRAMEWORK_BUILD_TEMP
	mkdir -p "$TEMP_DIR_PATH"


	# Build iPhone Simulator XCArchive

	IPHONESIMULATOR_XCARCHIVE_PATH="$TEMP_DIR_PATH"/"$scheme"-iphonesimulator.xcarchive

	xcodebuild archive \
	-project "$project" \
	-scheme "$scheme" \
	-archivePath "$IPHONESIMULATOR_XCARCHIVE_PATH" \
	-sdk iphonesimulator \
	SKIP_INSTALL=NO \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES


	# Build iPhone OS XCArchive

	IPHONEOS_XCARCHIVE_PATH="$TEMP_DIR_PATH"/"$scheme"-iphoneos.xcarchive

	xcodebuild archive \
	-project "$project" \
	-scheme "$scheme" \
	-archivePath "$IPHONEOS_XCARCHIVE_PATH" \
	-sdk iphoneos \
	SKIP_INSTALL=NO \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES


	# XCFramework

	OUTPUT="$outputdir"/"$name".xcframework

	rm -r -f "$OUTPUT"

	xcodebuild \
	-create-xcframework \
	-framework "$IPHONESIMULATOR_XCARCHIVE_PATH"/Products/Library/Frameworks/"$scheme".framework \
	-framework "$IPHONEOS_XCARCHIVE_PATH"/Products/Library/Frameworks/"$scheme".framework \
	-output "$OUTPUT"


	# Clear Temp directory

	rm -r -f "$TEMP_DIR_PATH"

	# Copy

	COPY_TO_PATH="$copy"

	if [ -n "$copy" ]; then 
		if [ -d "$COPY_TO_PATH" ]; then
			cp -R "$OUTPUT" "$COPY_TO_PATH"
		else
			log "copy: Directory, specified with the -copy option, not exist."
		fi
	fi
}