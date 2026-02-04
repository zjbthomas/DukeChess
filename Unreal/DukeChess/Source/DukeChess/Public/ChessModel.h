// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

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

	FString Name = "";
	int32 Version = 1;

	FIntPoint FrontCenterOffset{ 0, 0 };
	FIntPoint BackCenterOffset{ 0, 0 };

	bool bFront = true;
};
