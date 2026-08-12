--薄幸の乙女
-- 效果：
-- 以表侧攻击表示存在的这张卡不会被战斗破坏。只要这张卡以表侧攻击表示存在于场上，与这张卡进行过战斗的怪兽不能再攻击及改变表示形式。（伤害计算适用）
function c27618634.initial_effect(c)
	-- 以表侧攻击表示存在的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(c27618634.indcon)
	c:RegisterEffect(e1)
	-- 与这张卡进行过战斗的怪兽不能再攻击及改变表示形式。（伤害计算适用）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c27618634.atop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	-- 只要这张卡以表侧攻击表示存在于场上，与这张卡进行过战斗的怪兽不能再攻击及改变表示形式。（伤害计算适用）
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
	-- 只要这张卡以表侧攻击表示存在于场上，与这张卡进行过战斗的怪兽不能再攻击及改变表示形式。（伤害计算适用）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetOperation(c27618634.posop)
	c:RegisterEffect(e5)
end
-- 判断效果是否生效：只有当此卡处于表侧攻击表示时效果才生效。
function c27618634.indcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 记录与该卡战斗过的怪兽，并为其注册标识效果，用于后续判断是否禁止其攻击和改变表示形式。
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
-- 判断是否已记录过战斗过的怪兽：只有当此卡已记录过战斗过的怪兽时才触发禁止攻击效果。
function c27618634.atlcon(e)
	return e:GetHandler():GetFlagEffect(27618634)~=0
end
-- 判断目标怪兽是否为与该卡战斗过的怪兽，并且该怪兽是否拥有标识效果，决定是否禁止其攻击。
function c27618634.atltg(e,c)
	return e:GetLabelObject():IsContains(c) and c:GetFlagEffect(27618635)~=0
end
-- 当此卡表示形式改变时，清除其记录的战斗怪兽信息。
function c27618634.posop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(27618634)
end
