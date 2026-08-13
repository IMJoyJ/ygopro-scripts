--E・HERO アブソルートZero
-- 效果：
-- 名字带有「英雄」的怪兽＋水属性怪兽
-- 这张卡不能作融合召唤以外的特殊召唤。这张卡的攻击力上升场上表侧表示存在的「元素英雄 绝对零度侠」以外的水属性怪兽数量×500的数值。这张卡从场上离开时，对方场上存在的怪兽全部破坏。
function c40854197.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「英雄」字段怪兽和水属性怪兽各1只作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WATER),true)
	-- 这张卡不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为仅允许融合召唤（召唤类型必须为融合召唤）。
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
-- 定义攻击力上升的筛选条件：场上表侧表示、不是「元素英雄 绝对零度侠」自身、且属性为水属性的怪兽。
function c40854197.atkfilter(c)
	return c:IsFaceup() and not c:IsCode(40854197) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 计算攻击力上升值：统计双方场上满足条件的表侧水属性怪兽数量，每只上升500攻击力。
function c40854197.atkup(e,c)
	-- 返回满足条件的怪兽数量×500，作为这张卡的攻击力上升数值。
	return Duel.GetMatchingGroupCount(c40854197.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)*500
end
-- 离场效果发动条件：这张卡在离场前处于表侧表示，且离开前的所在位置为场上。
function c40854197.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 该效果发动时不取对象，仅登记破坏对方场上全部怪兽的操作信息；若为效果发动时点检查则直接通过。
function c40854197.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上当前存在的全部怪兽（作为效果处理时可能被破坏的全部对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将本次破坏的操作信息登记为破坏对方场上全部怪兽，数量为对方场上怪兽总数，以便相关效果联动。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时实际执行：再次获取对方场上当前存在的全部怪兽，并将其全部破坏。
function c40854197.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前存在的全部怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果为原因将这些怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
