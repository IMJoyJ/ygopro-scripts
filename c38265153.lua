--電脳エナジーショック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「人造人-念力震慑者」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。这个效果把场上的陷阱卡破坏的场合，可以再从以下效果选择1个适用。
-- ●选场上1张表侧表示的卡，那个效果直到回合结束时无效。
-- ●自己场上的全部「人造人-念力震慑者」的攻击力上升800。
function c38265153.initial_effect(c)
	-- 给本卡记录它效果文中提到的「人造人-念力震慑者」（卡号77585513），用于相关判定。
	aux.AddCodeList(c,77585513)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「人造人-念力震慑者」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。这个效果把场上的陷阱卡破坏的场合，可以再从以下效果选择1个适用。●选场上1张表侧表示的卡，那个效果直到回合结束时无效。●自己场上的全部「人造人-念力震慑者」的攻击力上升800。
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
-- 判断一张卡是否为表侧表示的「人造人-念力震慑者」（卡号77585513）。
function c38265153.cfilter(c)
	return c:IsCode(77585513) and c:IsFaceup()
end
-- 发动条件：自己场上有表侧表示的「人造人-念力震慑者」存在时才能发动。
function c38265153.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1张表侧表示的「人造人-念力震慑者」。
	return Duel.IsExistingMatchingCard(c38265153.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 目标处理：选择场上1张卡（本卡除外）作为破坏对象，并设定破坏的操作信息。
function c38265153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 效果发动合法性检查：场上存在除本卡外的可成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择1张卡（本卡除外）作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置破坏相关的连锁操作信息（用于后续影响破坏发动时点）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏对象卡；若破坏的是陷阱卡，则进一步提供两个可选效果让玩家适用。
function c38265153.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次连锁中作为对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 对象仍与效果关联、破坏成功且被破坏的卡是陷阱卡时，才执行后续选项处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_TRAP) then
		-- 收集场上可被无效化的表侧表示卡，作为「选卡无效」选项的候选集合。
		local g1=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		-- 收集自己场上表侧表示的「人造人-念力震慑者」，作为「攻击力上升」选项的候选集合。
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
			-- 玩家从可选项中决定适用的效果（0为不适用）。
			op=Duel.SelectOption(tp,table.unpack(ops))
		end
		if opval[op]==1 then
			-- 中断当前效果处理，使后续无效效果的适用拥有独立的时点。
			Duel.BreakEffect()
			-- 提示玩家选择要无效的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local sg=g1:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			-- 把对象卡相关的连锁效果一并无效化，并设定回合结束时重置。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那个效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那个效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那个效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
		if opval[op]==2 then
			-- 中断当前效果处理，使随后的攻击力上升作为独立的效果处理。
			Duel.BreakEffect()
			local tc=g2:GetFirst()
			while tc do
				-- 自己场上的全部「人造人-念力震慑者」的攻击力上升800。
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
