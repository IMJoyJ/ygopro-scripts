--エレキャッスル
-- 效果：
-- 只要这张卡在场上存在，向名字带有「电气」的怪兽攻击的怪兽的攻击力在那次伤害计算后下降1000。
function c58924378.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 向名字带有「电气」的怪兽攻击的怪兽的攻击力在那次伤害计算后下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c58924378.atkcon)
	e2:SetOperation(c58924378.atkop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，向名字带有「电气」的怪兽攻击的怪兽的攻击力在那次伤害计算后下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c58924378.target)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end
-- 检查怪兽是否带有当前「电气城堡」对应的FieldID标记，以此作为攻击力下降效果的影响对象。
function c58924378.target(e,c)
	local fid=e:GetHandler():GetFieldID()
	return c:GetFlagEffect(58924378)~=0 and c:GetFlagEffectLabel(58924378)==fid
end
-- 确认伤害计算后，被攻击的怪兽是「电气」怪兽，且攻击怪兽尚未被当前「电气城堡」标记。
function c58924378.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的怪兽。
	local d=Duel.GetAttackTarget()
	return d and d:IsSetCard(0xe) and not c58924378.target(e,a)
end
-- 给攻击了「电气」怪兽的怪兽注册一个带有当前「电气城堡」FieldID的标识效果，使其攻击力永久下降。
function c58924378.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽。
	local a=Duel.GetAttacker()
	local fid=e:GetHandler():GetFieldID()
	a:RegisterFlagEffect(58924378,RESETS_STANDARD,0,1,fid)
end
