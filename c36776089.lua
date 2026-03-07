--神騎セイントレア
-- 效果：
-- 2星怪兽×2
-- ①：持有超量素材的这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。那只对方怪兽回到手卡。
function c36776089.initial_effect(c)
	-- 添加XYZ召唤手续，使用2星怪兽叠放，最少2只，最多2只
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 持有超量素材的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c36776089.incon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。那只对方怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36776089,0))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c36776089.retcon)
	e2:SetCost(c36776089.retcost)
	e2:SetTarget(c36776089.rettg)
	e2:SetOperation(c36776089.retop)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：持有超量素材
function c36776089.incon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果发动的条件：战斗中对方怪兽存在且双方怪兽均未离场
function c36776089.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle()
end
-- 效果发动的代价：支付1个超量素材
function c36776089.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果的发动目标：对方怪兽
function c36776089.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定目标为对方怪兽，分类为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 效果处理：将对方怪兽送回手牌
function c36776089.retop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
