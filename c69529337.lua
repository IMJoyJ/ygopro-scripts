--トラミッド・ダンサー
-- 效果：
-- ①：1回合1次，以自己墓地1张「三形金字塔」卡为对象才能发动。那张卡回到卡组，自己场上的岩石族怪兽的攻击力·守备力上升500。
-- ②：对方回合1次，以自己场上1张「三形金字塔」场地魔法卡为对象才能发动。那张卡送去墓地，从卡组把和那张卡卡名不同的1张「三形金字塔」场地魔法卡发动。
function c69529337.initial_effect(c)
	-- ①：1回合1次，以自己墓地1张「三形金字塔」卡为对象才能发动。那张卡回到卡组，自己场上的岩石族怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69529337,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c69529337.tdtg)
	e1:SetOperation(c69529337.tdop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，以自己场上1张「三形金字塔」场地魔法卡为对象才能发动。那张卡送去墓地，从卡组把和那张卡卡名不同的1张「三形金字塔」场地魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69529337,1))  --"场地魔法卡发动"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c69529337.condition)
	e2:SetTarget(c69529337.target)
	e2:SetOperation(c69529337.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的「三形金字塔」卡且能回到卡组
function c69529337.tdfilter(c)
	return c:IsSetCard(0xe2) and c:IsAbleToDeck()
end
-- 过滤条件：自己场上表侧表示的岩石族怪兽
function c69529337.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK)
end
-- ①号效果的靶向/发动准备阶段（Target）
function c69529337.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69529337.tdfilter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的「三形金字塔」卡
	if chk==0 then return Duel.IsExistingTarget(c69529337.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 且自己场上存在表侧表示的岩石族怪兽
		and Duel.IsExistingMatchingCard(c69529337.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张「三形金字塔」卡作为效果对象
	local g=Duel.SelectTarget(tp,c69529337.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①号效果的执行阶段（Operation）
function c69529337.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合效果，则将其送回卡组并洗牌，确认其已成功回到卡组或额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取自己场上所有表侧表示的岩石族怪兽
		local g=Duel.GetMatchingGroup(c69529337.atkfilter,tp,LOCATION_MZONE,0,nil)
		local sc=g:GetFirst()
		while sc do
			-- 自己场上的岩石族怪兽的攻击力·守备力上升500
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
			sc=g:GetNext()
		end
	end
end
-- 过滤条件：卡组中与当前场地卡卡名不同、且可以发动的「三形金字塔」场地魔法卡
function c69529337.filter(c,tp,code)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0xe2) and c:GetActivateEffect():IsActivatable(tp,true,true) and not c:IsCode(code)
end
-- ②号效果的发动条件：对方回合
function c69529337.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- ②号效果的靶向/发动准备阶段（Target）
function c69529337.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场地区域的卡
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0xe2) and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
		-- 且卡组中存在与该卡卡名不同的可发动的「三形金字塔」场地魔法卡
		and Duel.IsExistingMatchingCard(c69529337.filter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode()) end
	-- 将自己场上的场地魔法卡设为效果对象
	Duel.SetTargetCard(tc)
	-- 设置操作信息：将选中的场地魔法卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
-- ②号效果的执行阶段（Operation）
function c69529337.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的场地魔法卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合效果，则将其送去墓地，并确认已成功送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组选择1张与送去墓地的卡卡名不同的「三形金字塔」场地魔法卡
		local g=Duel.SelectMatchingCard(tp,c69529337.filter,tp,LOCATION_DECK,0,1,1,nil,tp,tc:GetCode())
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的场地魔法卡在自己的场地区域表侧表示发动
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发场地魔法卡发动的相关时点
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
