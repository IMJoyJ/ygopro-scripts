--No.2 ゲート・オブ・ヌメロン－ドゥヴェー
-- 效果：
-- 1星怪兽×3
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
function c42230449.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用3只1星怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42230449,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCost(c42230449.atkcost)
	e2:SetCondition(c42230449.atkcon)
	e2:SetTarget(c42230449.atktg)
	e2:SetOperation(c42230449.atkop)
	c:RegisterEffect(e2)
end
-- 将这张卡的『No.』编号登记为2，用于规则上的No.卡相关判定。
aux.xyz_number[42230449]=2
-- ②效果的发动代价：取除这张卡的1个超量素材（先检查是否能取除，然后实际取除）。
function c42230449.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的发动条件：这张卡与对方怪兽进行过战斗，且在伤害步骤结束时仍与本次战斗关联（未离场）。
function c42230449.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 定义『源数』怪兽的过滤条件：表侧表示且属于0x14a（源数）系列。
function c42230449.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14a)
end
-- ②效果的发动目标检查：确认自己场上有至少1只表侧表示『源数』怪兽，以确定能否发动。
function c42230449.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的合法性检查：自己场上是否已存在至少1只满足过滤条件的『源数』怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c42230449.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果的结算：将自己场上全部『源数』怪兽的攻击力直到回合结束时变成2倍。
function c42230449.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足条件的『源数』怪兽集合。
	local g=Duel.GetMatchingGroup(c42230449.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
