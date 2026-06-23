--No.4 ゲート・オブ・ヌメロン－チャトゥヴァーリ
-- 效果：
-- 1星怪兽×3
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
function c4019153.initial_effect(c)
	-- 添加XYZ召唤手续，使用1星怪兽3只进行叠放
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
	e2:SetDescription(aux.Stringid(4019153,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCost(c4019153.atkcost)
	e2:SetCondition(c4019153.atkcon)
	e2:SetTarget(c4019153.atktg)
	e2:SetOperation(c4019153.atkop)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为4
aux.xyz_number[4019153]=4
-- 费用处理：检查并移除1个超量素材作为发动代价
function c4019153.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动条件：确认此卡参与了战斗且处于战斗状态
function c4019153.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 过滤函数：筛选场上表侧表示的「源数」怪兽
function c4019153.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14a)
end
-- 效果目标：确认场上存在至少1只「源数」怪兽
function c4019153.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果目标：确认场上存在至少1只「源数」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4019153.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：将场上所有「源数」怪兽的攻击力变为2倍
function c4019153.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「源数」怪兽组
	local g=Duel.GetMatchingGroup(c4019153.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每只符合条件的怪兽设置攻击力翻倍效果
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
