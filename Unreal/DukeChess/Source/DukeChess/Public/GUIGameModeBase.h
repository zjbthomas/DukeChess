// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "GUIGameModeBase.generated.h"

class AGUIPlayerController;

UENUM(BlueprintType)
enum class EUILevelKind : uint8
{
	InitLoad,
	ModeLoad,
	Others
};

/**
 * 
 */
UCLASS()
class DUKECHESS_API AGUIGameModeBase : public AGameModeBase
{
	GENERATED_BODY()
	
public:
	AGUIGameModeBase();

	// Prevent pawn spawning for UI maps
	virtual void RestartPlayer(AController* NewPlayer) override;

	UPROPERTY(EditDefaultsOnly, Category = "UI")
	EUILevelKind UILevelKind = EUILevelKind::Others;
};
