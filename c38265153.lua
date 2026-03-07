--電脳エナジーショック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「人造人-念力震慑者」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。这个效果把场上的陷阱卡破坏的场合，可以再从以下效果选择1个适用。
-- ●选场上1张表侧表示的卡，那个效果直到回合结束时无效。
-- ●自己场上的全部「人造人-念力震慑者」的攻击力上升800。
function c38265153.initial_effect(c)
	-- 记录此卡具有「人造人-念力震慑者」的卡名
	aux.AddCodeList(c,77585513)
	-- ①：自己场上有「人造人-念力震慑者」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。这个效果把场上的陷阱卡破坏的场合，可以再从以下效果选择1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38265153+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c38265153.condition)
	e1:SetTarget(c38265153.target)
	e1:SetOperation(c38265153.activate)
	c:RegisterEffect(e1)
end
-- 判断场上是否存在表侧表示的「人造人-念力震慑者」
function c38265153.cfilter(c)
	return c:IsCode(77585513) and c:IsFaceup()
end
-- 判断自己场上是否存在表侧表示的「人造人-念力震慑者」
function c38265153.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在表侧表示的「人造人-念力震慑者」
	return Duel.IsExistingMatchingCard(c38265153.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置效果目标，选择场上1张卡作为破坏对象
function c38265153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果发动后的操作
function c38265153.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效且被破坏，且为陷阱卡时触发后续选择
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_TRAP) then
		-- 获取场上所有可成为无效化对象的卡
		local g1=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		-- 获取自己场上所有表侧表示的「人造人-念力震慑者」
		local g2=Duel.GetMatchingGroup(c38265153.cfilter,tp,LOCATION_MZONE,0,nil)
		local off=1
		local ops={}
		local opval={}
		ops[off]=aux.Stringid(38265153,0)  --"不选择效果"
		opval[off-1]=0
		off=off+1
		if #g1>0 then
			ops[off]=aux.Stringid(38265153,1)  --"选卡无效"
			opval[off-1]=1
			off=off+1
		end
		if #g2>0 then
			ops[off]=aux.Stringid(38265153,2)  --"攻击力上升"
			opval[off-1]=2
			off=off+1
		end
		local op=0
		if #ops>1 then
			-- 让玩家从可选效果中选择一个
			op=Duel.SelectOption(tp,table.unpack(ops))
		end
		if opval[op]==1 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要无效的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local sg=g1:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			-- 使目标卡相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标卡效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标卡效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使目标陷阱怪兽无效化
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
		if opval[op]==2 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			local tc=g2:GetFirst()
			while tc do
				-- 使目标「人造人-念力震慑者」攻击力上升800
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(800)
				tc:RegisterEffect(e1)
				tc=g2:GetNext()
			end
		end
	end
end
