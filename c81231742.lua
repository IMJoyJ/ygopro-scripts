--破邪の魔法壁
-- 效果：
-- ①：自己场上的怪兽在自己回合内攻击力上升300，对方回合内守备力上升300。
function c81231742.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽在自己回合内攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c81231742.atkcon)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetCondition(c81231742.defcon)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升效果的生效条件函数，仅在自己回合时生效
function c81231742.atkcon(e)
	-- 判断当前回合玩家是否为这张卡的控制者（即自己回合）
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 定义守备力上升效果的生效条件函数，仅在对方回合时生效
function c81231742.defcon(e)
	-- 判断当前回合玩家是否不等于这张卡的控制者（即对方回合）
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
