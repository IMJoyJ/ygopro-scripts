--薄幸の乙女
-- 效果：
-- 以表侧攻击表示存在的这张卡不会被战斗破坏。只要这张卡以表侧攻击表示存在于场上，与这张卡进行过战斗的怪兽不能再攻击及改变表示形式。（伤害计算适用）
function c27618634.initial_effect(c)
	-- 对应效果原文：「以表侧攻击表示存在的这张卡不会被战斗破坏。」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(c27618634.indcon)
	c:RegisterEffect(e1)
	-- 对应效果原文：「与这张卡进行过战斗的怪兽不能再攻击及改变表示形式。（伤害计算适用）」
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c27618634.atop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	-- 对应效果原文：「只要这张卡以表侧攻击表示存在于场上，与这张卡进行过战斗的怪兽不能再攻击」
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c27618634.atlcon)
	e3:SetTarget(c27618634.atltg)
	e3:SetLabelObject(g)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetLabelObject(g)
	c:RegisterEffect(e4)
	-- 对应效果原文：「只要这张卡以表侧攻击表示存在于场上」；表示形式改变时清除标识，使该条件不再满足。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetOperation(c27618634.posop)
	c:RegisterEffect(e5)
end
-- 作为e1的适用条件：检查这张卡是否处于表侧攻击表示；只有表侧攻击表示时才适用不会被战斗破坏的效果。
function c27618634.indcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 伤害计算后触发：若这张卡与怪兽进行过战斗且自身仍为表侧攻击表示，则首次给自身标记27618634并清空旧记录，将战斗过的怪兽加入标签组并给该怪兽标记27618635，使其后续受不能攻击/不能改变表示形式的限制。
function c27618634.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and c:IsPosition(POS_FACEUP_ATTACK) then
		if c:GetFlagEffect(27618634)==0 then
			c:RegisterFlagEffect(27618634,RESET_EVENT+RESETS_STANDARD,0,1)
			e:GetLabelObject():Clear()
		end
		e:GetLabelObject():AddCard(bc)
		bc:RegisterFlagEffect(27618635,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- e3/e4的适用条件：判断这张卡是否带有27618634标识，即是否在当前表侧攻击表示存在期间曾与怪兽战斗过且尚未因表示形式变化等被重置。
function c27618634.atlcon(e)
	return e:GetHandler():GetFlagEffect(27618634)~=0
end
-- e3/e4的对象判定：只对记录在标签组中且带有27618635标识的怪兽，也就是与这张卡实际战斗过的怪兽，施加限制。
function c27618634.atltg(e,c)
	return e:GetLabelObject():IsContains(c) and c:GetFlagEffect(27618635)~=0
end
-- 当这张卡改变表示形式时，清除自身的27618634标识，使e3/e4的条件不再满足，从而解除对之前战斗过的怪兽的不能攻击/不能改变表示形式的限制。
function c27618634.posop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(27618634)
end
