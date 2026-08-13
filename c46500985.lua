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
	-- ①中攻击力部分：自己场上的「炼装」怪兽的攻击力上升300（原效果为攻击力·守备力各上升300，守备力部分由e3克隆实现）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设定增益效果的适用对象：筛选自己场上满足卡名含「炼装」（setname=0xe1）的怪兽，这些怪兽获得攻击力上升的效果
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
-- ②效果的发动/适用条件：检查自己灵摆区域是否存在至少1张「炼装」卡，满足时免疫效果才适用
function c46500985.immcon(e)
	-- 返回是否满足条件：自己灵摆区域存在1张以上的「炼装」卡（存在即返回true）
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil,0xe1)
end
-- 免疫效果的适用对象判定：被保护的怪兽必须是自己场上卡名含「炼装」且不是效果怪兽的怪兽
function c46500985.etarget(e,c)
	return c:IsSetCard(0xe1) and not c:IsType(TYPE_EFFECT)
end
-- 免疫来源判定：只免除对方效果的影响——效果来源的持有者不是本卡控制者时，该效果无效
function c46500985.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
