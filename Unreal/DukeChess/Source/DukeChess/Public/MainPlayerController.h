// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "BoardActor.h"

#include "Kismet/GameplayStatics.h"

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "MainPlayerController.generated.h"

/**
 * 
 */
UCLASS()
class DUKECHESS_API AMainPlayerController : public APlayerController
{
	GENERATED_BODY()

protected:
	virtual void BeginPlay() override;

    virtual void PlayerTick(float DeltaTime) override;

	virtual void SetupInputComponent() override;

private:
    UPROPERTY()
    TObjectPtr<ABoardActor> Board = nullptr;

    void FindBoard();

    bool bRotatingBoard = false;

    // Tuning: degrees per mouse unit (mouse Y delta)
    UPROPERTY(EditAnywhere, Category = "Input|Board")
    float PitchSpeed = 0.15f;

    UPROPERTY(EditDefaultsOnly, Category = "Input|Board", meta = (ClampMin = "0.01", ClampMax = "20.0"))
    float PitchInterpSpeed = 8.0f;   // higher = snappier

    float TargetPitch = 0.0f;

    void OnRMBPressed();
    void OnRMBReleased();
    void OnMMBPressed();

    void OnMouseY(float Value);
};
