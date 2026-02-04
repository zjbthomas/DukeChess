// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "ChessLoader.h"

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "GlobalGameInstance.generated.h"

/**
 * 
 */
UCLASS()
class DUKECHESS_API UGlobalGameInstance : public UGameInstance
{
	GENERATED_BODY()
	
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Board")
	int32 MAXR = 6;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Board")
	int32 MAXC = 6;

	// Chess
	TUniquePtr<ChessLoader> ChessLoaderInstance;

	LoadChessResult LoadChess();

	// Mode
	UPROPERTY(BlueprintReadWrite, Category = "Mode")
	bool bLocal = false;
	UPROPERTY(BlueprintReadWrite, Category = "Mode")
	bool bAI = false;

	static FIntPoint DestToOffsetsForChess(FString Dest) {
		int32 x = 0;
		int32 y = 0;

		for (TCHAR C : Dest) {
			switch (C) {
			case 'U':
				y -= 1;
				break;
			case 'D':
				y += 1;
				break;
			case 'L':
				x -= 1;
				break;
			case 'R':
				x += 1;
				break;
			}
		}

		return FIntPoint{ x, y };
	}
};
