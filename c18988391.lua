--アマリリース
-- 效果：
-- 自己的主要阶段时，把墓地的这张卡从游戏中除外才能发动。这个回合只有1次，自己把怪兽召唤的场合需要的解放可以减少1只。「解放朱顶红」的效果1回合只能发动1次。
function c18988391.initial_effect(c)
	-- 自己的主要阶段时，把墓地的这张卡从游戏中除外才能发动。「解放朱顶红」的效果1回合只能发动1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18988391,0))  --"解放数量降低"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,18988391)
	-- 设置效果发动的代价：将墓地中的这张卡从游戏中除外（aux.bfgcost 实现除外自身作为COST）。
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c18988391.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时，创建一个本回合持续的效果：自己手牌中的怪兽进行召唤时所需的解放数减少1只，且该削减效果本回合只能适用1次，并在结束阶段重置。
function c18988391.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合只有1次，自己把怪兽召唤的场合需要的解放可以减少1只。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的减少解放效果注册到决斗中，使其对当前回合玩家（自己）生效，并在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
