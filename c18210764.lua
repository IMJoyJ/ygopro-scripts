--ペンデュラムーチョ
-- 效果：
-- ←0 【灵摆】 0→
-- ①：这张卡发动的回合的自己主要阶段只有1次，从自己墓地的怪兽或者除外的自己怪兽之中以「灵摆多福鸟」以外的1只灵摆怪兽为对象才能发动。那只灵摆怪兽表侧表示加入自己的额外卡组。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的额外卡组把「灵摆多福鸟」以外的1只表侧表示的1星灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c18210764.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：这张卡发动的回合的自己主要阶段只有1次，从自己墓地的怪兽或者除外的自己怪兽之中以「灵摆多福鸟」以外的1只灵摆怪兽为对象才能发动。那只灵摆怪兽表侧表示加入自己的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c18210764.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的额外卡组把「灵摆多福鸟」以外的1只表侧表示的1星灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18210764,0))  --"加入额外卡组"
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c18210764.tecon)
	e2:SetTarget(c18210764.tetg)
	e2:SetOperation(c18210764.teop)
	c:RegisterEffect(e2)
	-- 为灵摆多福鸟添加灵摆怪兽属性，不注册灵摆卡的发动效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18210764,2))  --"额外卡组灵摆怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c18210764.sptg)
	e3:SetOperation(c18210764.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 注册flag标记，用于记录该卡已发动
function c18210764.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(18210764,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断是否已发动过效果
function c18210764.tecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(18210764)>0
end
-- 过滤满足条件的灵摆怪兽（表侧表示或在墓地，且不是灵摆多福鸟）
function c18210764.tefilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_PENDULUM)
		and not c:IsCode(18210764)
end
-- 设置选择目标的过滤条件，选择墓地或除外区的灵摆怪兽
function c18210764.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c18210764.tefilter(chkc) end
	-- 检查是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingTarget(c18210764.tefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入额外卡组的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18210764,1))  --"请选择要加入自己的额外卡组的卡"
	-- 选择满足条件的灵摆怪兽作为目标
	local g=Duel.SelectTarget(tp,c18210764.tefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将目标卡加入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示目标卡将离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 执行将目标卡加入额外卡组的操作
function c18210764.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以灵摆卡形式加入额外卡组
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end
-- 过滤满足条件的1星灵摆怪兽（非灵摆多福鸟，可特殊召唤，且有召唤位置）
function c18210764.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLevel(1)
		-- 排除灵摆多福鸟，检查是否可特殊召唤，检查是否有召唤位置
		and not c:IsCode(18210764) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤目标的过滤条件，选择额外卡组中的1星灵摆怪兽
function c18210764.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的1星灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18210764.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从额外卡组特殊召唤1只灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作，并设置特殊召唤怪兽离开场上的处理
function c18210764.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的灵摆怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c18210764.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 判断是否成功特殊召唤，并设置离开场上的处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤怪兽离开场上时被除外的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
