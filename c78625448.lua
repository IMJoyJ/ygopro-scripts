--No.3 ゲート・オブ・ヌメロン－トゥリーニ
-- 效果：
-- 1星怪兽×3
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
function c78625448.initial_effect(c)
	-- 添加XYZ召唤手续：1星怪兽×3
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
	e2:SetDescription(aux.Stringid(78625448,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCost(c78625448.atkcost)
	e2:SetCondition(c78625448.atkcon)
	e2:SetTarget(c78625448.atktg)
	e2:SetOperation(c78625448.atkop)
	c:RegisterEffect(e2)
end
-- 设置该卡片的“No.”数值为3
aux.xyz_number[78625448]=3
-- 效果②的Cost：检查并取除这张卡的1个超量素材
function c78625448.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的Condition：检查这张卡是否与对方怪兽进行过战斗且仍在场上
function c78625448.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 过滤条件：自己场上表侧表示的「源数」怪兽
function c78625448.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14a)
end
-- 效果②的Target：检查自己场上是否存在满足条件的「源数」怪兽
function c78625448.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己场上是否存在至少1只表侧表示的「源数」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78625448.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的Operation：使自己场上全部「源数」怪兽的攻击力直到回合结束时变成2倍
function c78625448.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「源数」怪兽
	local g=Duel.GetMatchingGroup(c78625448.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到回合结束时变成2倍。
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
