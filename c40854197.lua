--E・HERO アブソルートZero
-- 效果：
-- 名字带有「英雄」的怪兽＋水属性怪兽
-- 这张卡不能作融合召唤以外的特殊召唤。这张卡的攻击力上升场上表侧表示存在的「元素英雄 绝对零度侠」以外的水属性怪兽数量×500的数值。这张卡从场上离开时，对方场上存在的怪兽全部破坏。
function c40854197.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只名字带有「英雄」的怪兽和1只水属性怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WATER),true)
	-- 这张卡不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为禁止通过其他方式特殊召唤（仅限融合召唤）
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，对方场上存在的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40854197,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c40854197.descon)
	e2:SetTarget(c40854197.destg)
	e2:SetOperation(c40854197.desop)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升场上表侧表示存在的「元素英雄 绝对零度侠」以外的水属性怪兽数量×500的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(c40854197.atkup)
	c:RegisterEffect(e5)
end
c40854197.material_setcode=0x8
-- 定义用于计算攻击力提升的过滤函数，筛选场上正面表示的、非此卡本身的水属性怪兽
function c40854197.atkfilter(c)
	return c:IsFaceup() and not c:IsCode(40854197) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 计算满足条件的水属性怪兽数量，并乘以500作为攻击力提升值
function c40854197.atkup(e,c)
	-- 获取满足过滤条件的水属性怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(c40854197.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
-- 判断此卡离开场上的条件：必须是正面表示从场上离开
function c40854197.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置连锁处理时的破坏效果目标，将对方场上所有怪兽设为破坏对象
function c40854197.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，指定破坏效果的处理对象为对方场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将对方场上所有怪兽破坏
function c40854197.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 执行破坏操作，将目标怪兽以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
