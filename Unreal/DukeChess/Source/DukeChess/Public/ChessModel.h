// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "MovementManager.h"

class UTexture2D;

enum class EActionType : uint8
{
	MOVE,
	SUMMON,
	COMMAND
};

/**
 * 
 */
class DUKECHESS_API ChessModel
{
public:
	ChessModel();
	~ChessModel();

	static bool TryParseActionType(const FString& Str, EActionType& OutType)
	{
		const FName Name(*Str);

		if (Name == TEXT("Move")) { OutType = EActionType::MOVE; return true; }
		if (Name == TEXT("Summon")) { OutType = EActionType::SUMMON; return true; }
		if (Name == TEXT("Command")) { OutType = EActionType::COMMAND; return true; }

		return false;
	}

	FString Name = "";
	int32 Version = 1;

	FIntPoint FrontCenterOffset{ 0, 0 };
	FIntPoint BackCenterOffset{ 0, 0 };

	TMap<EActionType, TMap<FString, EMovementType>> FrontMap;
	TMap<EActionType, TMap<FString, EMovementType>> BackMap;

	TMap<EAuraType, TArray<FString>> FrontAuraMap;
	TMap<EAuraType, TArray<FString>> BackAuraMap;

	UTexture2D* Texture = nullptr;

	bool bFront = true;
};
