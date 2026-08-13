--神騎セイントレア
-- 效果：
-- 2星怪兽×2
-- ①：持有超量素材的这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。那只对方怪兽回到手卡。
function c36776089.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只2星怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c36776089.incon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。那只对方怪兽回到手卡。
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
-- ①效果的永续条件：这张卡持有超量素材时，才适用不会被战斗破坏的效果。
function c36776089.incon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- ②效果的诱发条件：这张卡与对方怪兽进行过战斗，且这张卡和战斗对象怪兽仍在场上且与本次战斗关联时可发动。
function c36776089.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle()
end
-- ②效果的发动代价：取除这张卡的1个超量素材（发动前检查能否取除）。
function c36776089.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的目标设定：以这张卡的战斗对象（对方怪兽）作为返回手牌的对象，发动时无需额外选择卡片。
function c36776089.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将1只战斗对象怪兽确定为返回手牌的对象。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- ②效果处理：若战斗对象的对方怪兽仍与本次战斗关联，则将其返回持有者手卡。
function c36776089.retop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将那只对方怪兽从场上返回持有者手卡（以效果处理的方式）。
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
