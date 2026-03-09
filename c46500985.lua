--メタモルF
-- 效果：
-- ①：自己场上的「炼装」怪兽的攻击力·守备力上升300。
-- ②：只要自己的灵摆区域有「炼装」卡存在，效果怪兽以外的自己场上的「炼装」怪兽不受对方的效果影响。
function c46500985.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「炼装」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 检索满足条件的「炼装」怪兽组
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe1))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要自己的灵摆区域有「炼装」卡存在，效果怪兽以外的自己场上的「炼装」怪兽不受对方的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c46500985.immcon)
	e4:SetTarget(c46500985.etarget)
	e4:SetValue(c46500985.efilter)
	c:RegisterEffect(e4)
end
-- 判断灵摆区是否存在「炼装」卡
function c46500985.immcon(e)
	-- 检查我方灵摆区是否有至少1张「炼装」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xe1)
end
-- 设定目标为非效果怪兽的「炼装」怪兽
function c46500985.etarget(e,c)
	return c:IsSetCard(0xe1) and not c:IsType(TYPE_EFFECT)
end
-- 过滤掉自身玩家发动的效果
function c46500985.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
