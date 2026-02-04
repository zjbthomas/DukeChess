// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

class UGlobalGameInstance;

class ChessModel;

struct LoadChessResult {
	bool bOK = true;

	FString ErrorMsg;
};

struct ManifestEntry
{
	FString JSONRelPath;
	FString PNGRelPath;
};

/**
 * 
 */
class DUKECHESS_API ChessLoader
{
public:
	ChessLoader(UGlobalGameInstance* InGlobal);
	~ChessLoader();

	const FString CONTENTCHESSPATH = FPaths::ProjectContentDir() / TEXT("Data/Chess");
	const FString SAVEDCHESSPATH = FPaths::ProjectSavedDir() / TEXT("Chess");
	const FString CHESSMANIFEST = TEXT("manifest.txt");
	const FString CHESSAMOUNTJSON = TEXT("chess_amount.json");
	const FString CHESSAMOUNTJSONONLINE = TEXT("chess_amount_online.json");

	UGlobalGameInstance* Global;

	TArray<FString> ChessNameArray;
	TMap<FString, int32> ChessMaxAmountMap;
	TMap<FString, TSharedPtr<ChessModel>> ChessModelMap;
	// TODO: ChessTextureMap

	LoadChessResult LoadChess();

private:
	bool LoadChessFromContent(LoadChessResult& R);
	bool LoadChessFromSaved(LoadChessResult& R);

	bool CopyToSaved(LoadChessResult& R);
	bool CopyFile(const FString& PakFilePath, const FString& DestFilePath);

	TArray<ManifestEntry> ReadManifestEntries(LoadChessResult& R);

};
