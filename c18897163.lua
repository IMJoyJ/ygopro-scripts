--DDD超死偉王ダークネス・ヘル・アーマゲドン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，另一边的自己的灵摆区域有「DD」卡存在的场合才能发动。从额外卡组把「DDD 超死伟王 黑地狱终末神」以外的1只「DDD」超量怪兽特殊召唤。
-- 【怪兽效果】
-- 8星「DDD」怪兽×2
-- ①：这张卡超量召唤成功时才能发动。选自己的额外卡组1只表侧表示的「DD」灵摆怪兽在这张卡下面重叠作为超量素材。
-- ②：自己场上的灵摆怪兽不会被效果破坏。
-- ③：1回合1次，把这张卡1个超量素材取除，以自己场上的灵摆怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
-- ④：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c18897163.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 为卡片添加XYZ召唤手续，使用满足条件的8星且属于「DDD」的怪兽作为素材进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x10af),8,2)
	-- ①：1回合1次，另一边的自己的灵摆区域有「DD」卡存在的场合才能发动。从额外卡组把「DDD 超死伟王 黑地狱终末神」以外的1只「DDD」超量怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18897163,0))  --"「DDD」超量怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c18897163.spcon)
	e1:SetTarget(c18897163.sptg)
	e1:SetOperation(c18897163.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡超量召唤成功时才能发动。选自己的额外卡组1只表侧表示的「DD」灵摆怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18897163,1))  --"补充超量素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c18897163.xyzcon)
	e2:SetTarget(c18897163.xyztg)
	e2:SetOperation(c18897163.xyzop)
	c:RegisterEffect(e2)
	-- ②：自己场上的灵摆怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上的灵摆怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除，以自己场上的灵摆怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18897163,2))  --"对方怪兽破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c18897163.descost)
	e4:SetTarget(c18897163.destg)
	e4:SetOperation(c18897163.desop)
	c:RegisterEffect(e4)
	-- ④：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(18897163,3))  --"这张卡在自己的灵摆区域放置"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c18897163.pencon)
	e6:SetTarget(c18897163.pentg)
	e6:SetOperation(c18897163.penop)
	c:RegisterEffect(e6)
end
-- 判断另一边的自己的灵摆区域是否有「DD」卡存在
function c18897163.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的自己的灵摆区域是否存在至少1张满足条件的「DD」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xaf)
end
-- 筛选满足条件的额外卡组中的「DDD」超量怪兽
function c18897163.spfilter(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsType(TYPE_XYZ) and not c:IsCode(18897163)
		-- 检查该怪兽是否可以特殊召唤且额外卡组有足够空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤效果的目标
function c18897163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的额外卡组怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18897163.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作
function c18897163.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组怪兽
	local g=Duel.SelectMatchingCard(tp,c18897163.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否为XYZ召唤成功
function c18897163.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选满足条件的额外卡组中的灵摆怪兽
function c18897163.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xaf) and c:IsCanOverlay()
end
-- 设置补充超量素材效果的目标
function c18897163.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的额外卡组灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18897163.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 执行补充超量素材操作
function c18897163.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取满足条件的额外卡组灵摆怪兽
	local g=Duel.GetMatchingGroup(c18897163.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local og=g:Select(tp,1,1,nil)
		-- 将选中的灵摆怪兽叠放至该卡上
		Duel.Overlay(c,og)
	end
end
-- 支付破坏效果的代价
function c18897163.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的场上的灵摆怪兽
function c18897163.descfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 设置破坏效果的目标
function c18897163.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 计算自己场上的灵摆怪兽数量
	local ct=Duel.GetMatchingGroupCount(c18897163.descfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否存在满足条件的对方怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,ct,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的对方怪兽
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 设置连锁操作信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作
function c18897163.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断该卡是否从怪兽区域被破坏
function c18897163.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标
function c18897163.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有可用的灵摆区域
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行灵摆区域放置操作
function c18897163.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
