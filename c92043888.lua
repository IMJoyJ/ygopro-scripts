--ドレミコード・フォーマル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的灵摆区域有「七音服」卡存在，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。从自己的额外卡组让1只表侧表示的灵摆怪兽回到卡组。那之后，以下效果适用。
-- ●自己场上的灵摆怪兽不受那个对方的效果影响。
-- ●自己的灵摆区域的卡不会被那个对方的效果破坏。
-- ●自己的灵摆区域的卡不能用那个对方的效果除外。
function c92043888.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的灵摆区域有「七音服」卡存在，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。从自己的额外卡组让1只表侧表示的灵摆怪兽回到卡组。那之后，以下效果适用。●自己场上的灵摆怪兽不受那个对方的效果影响。●自己的灵摆区域的卡不会被那个对方的效果破坏。●自己的灵摆区域的卡不能用那个对方的效果除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,92043888+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c92043888.condition)
	e1:SetTarget(c92043888.target)
	e1:SetOperation(c92043888.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己灵摆区域表侧表示的「七音服」卡
function c92043888.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162)
end
-- 发动条件：自己灵摆区域有「七音服」卡存在，且对方发动怪兽的效果或魔法·陷阱卡
function c92043888.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在至少1张表侧表示的「七音服」卡
	return Duel.IsExistingMatchingCard(c92043888.confilter,tp,LOCATION_PZONE,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and rp==1-tp
end
-- 过滤条件：额外卡组表侧表示且可以回到卡组的灵摆怪兽
function c92043888.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 效果发动准备（检查额外卡组是否有符合条件的卡，并设置操作信息为回到卡组）
function c92043888.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1张表侧表示的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92043888.tdfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：将自己额外卡组的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：场上表侧表示的灵摆怪兽
function c92043888.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 效果处理：让额外卡组1只表侧表示灵摆怪兽回到卡组，之后适用不受影响、不会被破坏、不能被除外的效果
function c92043888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己额外卡组1张表侧表示的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c92043888.tdfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 成功将选择的怪兽送回卡组并洗牌
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK)
		-- 检查自己场上是否存在表侧表示的灵摆怪兽（用于后续效果适用条件）
		and Duel.IsExistingMatchingCard(c92043888.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续适用效果与回到卡组不视为同时处理
		Duel.BreakEffect()
		-- ●自己场上的灵摆怪兽不受那个对方的效果影响。●自己的灵摆区域的卡不会被那个对方的效果破坏。●自己的灵摆区域的卡不能用那个对方的效果除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设置不受影响效果的对象为灵摆怪兽
		e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
		e1:SetValue(c92043888.efilter)
		e1:SetLabelObject(re)
		e1:SetReset(RESET_EVENT+RESET_CHAIN)
		-- 注册“不受那个对方的效果影响”的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_PZONE,0)
		-- 注册“不会被那个对方的效果破坏”的全局效果
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_REMOVE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,1)
		e3:SetTarget(c92043888.rmlimit)
		-- 注册“不能用那个对方的效果除外”的全局效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 过滤条件：仅针对本次连锁中对方发动的那个效果
function c92043888.efilter(e,re)
	return re==e:GetLabelObject()
end
-- 限制条件：防止自己灵摆区域的卡被本次连锁中对方发动的那个效果除外
function c92043888.rmlimit(e,c,tp,r,re)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_PZONE) and r&REASON_EFFECT~=0 and re and re==e:GetLabelObject()
end
