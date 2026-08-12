--星守る結界
-- 效果：
-- ①：场上的「星骑士」超量怪兽的攻击力·守备力上升那超量素材数量×200。
-- ②：自己场上的「星骑士」超量怪兽被选择作为攻击对象时，把手卡1张「星骑士」卡送去墓地才能发动。那次攻击无效。
function c70422863.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「星骑士」超量怪兽的攻击力·守备力上升那超量素材数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c70422863.atktg)
	e2:SetValue(c70422863.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己场上的「星骑士」超量怪兽被选择作为攻击对象时，把手卡1张「星骑士」卡送去墓地才能发动。那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCondition(c70422863.negcon)
	e4:SetCost(c70422863.negcost)
	e4:SetOperation(c70422863.negop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上的「星骑士」超量怪兽
function c70422863.atktg(e,c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x9c)
end
-- 计算上升的数值：该怪兽的超量素材数量×200
function c70422863.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 发动条件：自己场上表侧表示的「星骑士」超量怪兽被选择为攻击对象时
function c70422863.negcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsType(TYPE_XYZ) and tc:IsSetCard(0x9c)
		and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end
-- 过滤条件：手卡中可以作为发动代价送去墓地的「星骑士」卡
function c70422863.cfilter(c)
	return c:IsSetCard(0x9c) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡将1张「星骑士」卡送去墓地
function c70422863.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以送去墓地的「星骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70422863.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张「星骑士」卡作为发动代价送去墓地
	Duel.DiscardHand(tp,c70422863.cfilter,1,1,REASON_COST)
end
-- 效果处理：使那次攻击无效
function c70422863.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
