// Fill out your copyright notice in the Description page of Project Settings.


#include "GlobalGameInstance.h"

LoadChessResult UGlobalGameInstance::LoadChess() {
	UE_LOG(LogTemp, Warning, TEXT("bLocal %d, bAI %d"), bLocal, bAI);

	ChessLoaderInstance = MakeUnique<ChessLoader>(this);

	return ChessLoaderInstance->LoadChess();
}