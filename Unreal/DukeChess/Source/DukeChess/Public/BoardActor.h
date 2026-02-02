// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "BoardActor.generated.h"

class AChessTileActor;

UCLASS()
class DUKECHESS_API ABoardActor : public AActor
{
	GENERATED_BODY()
	
public:	
	// Sets default values for this actor's properties
	ABoardActor();

	UPROPERTY(VisibleAnywhere)
	USceneComponent* Root;

	UPROPERTY(EditAnywhere, Category="Board")
	TSubclassOf<AChessTileActor> ChessTileActorClass;

	// Change board pitch
	UFUNCTION(BlueprintCallable, Category = "Board")
	void SetBoardPitchDegrees(float PitchDeg);

	UFUNCTION(BlueprintCallable, Category = "Board")
	float GetBoardPitchDegrees() const;

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

	UFUNCTION()
	void HandleTileClicked(int32 Row, int32 Col);

public:	
	// Called every frame
	virtual void Tick(float DeltaTime) override;

private:
	float TileSize = 100.0f;

	void InitBoard();

};
