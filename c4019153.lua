--No.4 ゲート・オブ・ヌメロン－チャトゥヴァーリ
-- 效果：
-- 1星怪兽×3
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时，把这张卡1个超量素材取除才能发动。自己场上的全部「源数」怪兽的攻击力直到回合结束时变成2倍。
function c4019153.initial_effect(c)
	-- 为「No.4 源数之门-肆」添加XYZ召唤手续：可用任意3只1星怪兽叠放（1星怪兽×3）
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
-- 将这张卡的XYZ编号设定为4，供No.相关效果判定使用。
aux.xyz_number[4019153]=4
-- 发动代价处理：判定能否从这张卡上移除1个超量素材作为代价，可以则实际移除1个超量素材。
function c4019153.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动条件判定：这张卡与对方怪兽进行过战斗，且该卡仍与本次战斗关联（未在战斗处理中离场）。
function c4019153.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 定义「源数」怪兽的筛选条件：表侧表示且卡名含有「源数」。
function c4019153.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14a)
end
-- 效果发动目标判定：自己不取对象地确认场上存在至少1只表侧表示「源数」怪兽才能发动。
function c4019153.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上存在至少1只表侧表示「源数」怪兽（满足攻击力翻倍的对象存在）。
	if chk==0 then return Duel.IsExistingMatchingCard(c4019153.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取自己场上全部表侧表示「源数」怪兽，将每只怪兽的攻击力变为当前攻击力的2倍，持续到回合结束。
function c4019153.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足条件的「源数」怪兽组成集合。
	local g=Duel.GetMatchingGroup(c4019153.atkfilter,tp,LOCATION_MZONE,0,nil)
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
