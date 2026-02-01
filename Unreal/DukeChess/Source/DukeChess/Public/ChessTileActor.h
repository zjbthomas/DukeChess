// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "ChessTileActor.generated.h"

class UStaticMeshComponent;

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnChessTileClicked, int32, Row, int32, Col);

UCLASS()
class DUKECHESS_API AChessTileActor : public AActor
{
	GENERATED_BODY()
	
public:	
	// Sets default values for this actor's properties
	AChessTileActor();

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tile")
	int32 Row = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tile")
	int32 Col = 0;

	UFUNCTION(BlueprintCallable, Category = "Tile")
	void SetRC(int32 InRow, int32 InCol) { Row = InRow; Col = InCol; }

	UFUNCTION(BlueprintCallable, Category = "Tile")
	void UpdateMaterial();

	// Materials
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Tile")
	UMaterialInterface* Material1;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Tile")
	UMaterialInterface* Material2;

	// Signals
	UPROPERTY(BlueprintAssignable, Category = "Tile")
	FOnChessTileClicked OnTileClicked;

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

	// Components
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Tile")
	USceneComponent* Root;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Tile")
	UStaticMeshComponent* TileCube;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Tile")
	UStaticMeshComponent* SelectorPlane;

	// Hover callbacks (component-level is more reliable than actor-level)
	UFUNCTION()
	void HandleBeginCursorOver(UPrimitiveComponent* TouchedComponent);

	UFUNCTION()
	void HandleEndCursorOver(UPrimitiveComponent* TouchedComponent);

	// Click callback
	UFUNCTION()
	void HandleClicked(UPrimitiveComponent* TouchedComponent, FKey ButtonPressed);

public:	
	// Called every frame
	virtual void Tick(float DeltaTime) override;

};
