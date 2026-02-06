// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "ChessModel.h"
#include "MovementManager.h"

class UGlobalGameInstance;

struct LoadChessResult {
	bool bOK = true;

	FString ErrorMsg;
};

struct ManifestEntry
{
	FString JSONRelPath;
	FString PNGRelPath;
};

struct ParseMovementsResult {
	EActionType ActionType;
	TMap<FString, EMovementType> TargetMap;
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
	bool LoadChessFromJSON(const FString& Filename, const FString& ForceName, const FString& ImagePath, LoadChessResult& R);
	bool LoadChessMaxAmount(const FString& Filename, LoadChessResult& R);

	bool CopyToSaved(LoadChessResult& R);
	bool CopyFile(const FString& PakFilePath, const FString& DestFilePath);

	TArray<ManifestEntry> ReadManifestEntries(LoadChessResult& R);

	bool ParseMovements(TSharedPtr<FJsonObject>& Root, FString Key, TMap<EActionType, TMap<FString, EMovementType>>& InMap, LoadChessResult& R, const FString& Filename);
	bool ParseSingleMovement(TSharedPtr<FJsonObject>& Parent, LoadChessResult& R, const FString& Filename, ParseMovementsResult& PMR);

	bool ParseAura(TSharedPtr<FJsonObject>& Root, FString Key, TMap<EAuraType, TArray<FString>>& InMap, LoadChessResult& R, const FString& Filename);

	UTexture2D* LoadTexture2DFromFile(const FString& FilePath);

};
