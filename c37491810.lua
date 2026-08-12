--パラメタルフォーゼ・アゾートレス
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的表侧表示的「炼装」卡被效果破坏的场合，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- 「炼装」怪兽＋融合怪兽
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡从额外卡组的特殊召唤成功的场合，以对方场上1张卡为对象才能发动。从自己的额外卡组让2只表侧表示的灵摆怪兽回到卡组，作为对象的卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c37491810.initial_effect(c)
	c:EnableReviveLimit()
	-- 为怪兽添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 设置融合召唤手续，使用满足条件的融合素材进行融合召唤
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),true)
	-- ①：自己场上的表侧表示的「炼装」卡被效果破坏的场合，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37491810,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,37491810)
	e1:SetCondition(c37491810.despcon)
	e1:SetTarget(c37491810.desptg)
	e1:SetOperation(c37491810.despop)
	c:RegisterEffect(e1)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合，以对方场上1张卡为对象才能发动。从自己的额外卡组让2只表侧表示的灵摆怪兽回到卡组，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37491810,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,37491811)
	e2:SetCondition(c37491810.desmcon)
	e2:SetTarget(c37491810.desmtg)
	e2:SetOperation(c37491810.desmop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(98452268,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c37491810.pencon)
	e5:SetTarget(c37491810.pentg)
	e5:SetOperation(c37491810.penop)
	c:RegisterEffect(e5)
end
-- 过滤满足条件的被破坏卡片：因效果破坏、之前为炼装卡组、之前在自己场上、之前正面表示
function c37491810.filter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousSetCard(0xe1)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否有满足条件的被破坏卡片
function c37491810.despcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37491810.filter,1,nil,tp)
end
-- 设置选择目标：选择场上正面表示的卡
function c37491810.desptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件：场上存在正面表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上正面表示的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果：破坏目标卡
function c37491810.despop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否为从额外卡组特殊召唤成功
function c37491810.desmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤满足条件的灵摆怪兽：正面表示、类型为灵摆、能回到卡组
function c37491810.desmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 设置选择目标：选择对方场上的卡作为破坏对象
function c37491810.desmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 判断是否满足选择目标的条件：对方场上存在卡且自己额外卡组存在2只满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(c37491810.desmfilter,tp,LOCATION_EXTRA,0,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将2只灵摆怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_EXTRA)
	-- 设置操作信息：破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果：选择2只灵摆怪兽送回卡组并破坏目标卡
function c37491810.desmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c37491810.desmfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	-- 显示选择的卡被选为对象的动画
	Duel.HintSelection(g)
	-- 判断是否满足效果处理条件：送回卡组成功且目标卡存在且有效
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否为从怪兽区域被破坏且正面表示
function c37491810.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置选择目标：检查灵摆区域是否可用
function c37491810.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足选择目标的条件：灵摆区域有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 处理效果：将怪兽移至灵摆区域
function c37491810.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将怪兽移至灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
