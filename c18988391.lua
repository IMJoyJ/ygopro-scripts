--アマリリース
-- 效果：
-- 自己的主要阶段时，把墓地的这张卡从游戏中除外才能发动。这个回合只有1次，自己把怪兽召唤的场合需要的解放可以减少1只。「解放朱顶红」的效果1回合只能发动1次。
function c18988391.initial_effect(c)
	-- 自己的主要阶段时，把墓地的这张卡从游戏中除外才能发动。这个回合只有1次，自己把怪兽召唤的场合需要的解放可以减少1只。「解放朱顶红」的效果1回合只能发动1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18988391,0))  --"解放数量降低"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,18988391)
	-- 将墓地的这张卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c18988391.operation)
	c:RegisterEffect(e1)
end
-- 设置效果在对方场上发动，使我方手牌怪兽召唤时解放减少1只
function c18988391.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使我方手牌怪兽召唤时解放减少1只
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
