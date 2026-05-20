--星辰の吼炎
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1张表侧表示的魔法卡为对象才能发动。那张卡的效果直到回合结束时无效。那之后，以下效果可以适用。
-- ●「星辰的吼炎」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1张表侧表示的魔法卡为对象才能发动。那张卡的效果直到回合结束时无效。那之后，以下效果可以适用。●「星辰的吼炎」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上可被无效的表侧表示魔法卡的条件函数
function s.negfilter(c)
	-- 检查卡片是否为场上可被无效的表侧表示魔法卡
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_SPELL)
end
-- 效果发动的靶向处理（Target）函数，处理发动条件、检查可行性并选择对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
	-- 检查场上是否存在至少1张符合条件的表侧表示魔法卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择1张符合条件的表侧表示魔法卡并将其作为效果对象
	Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 过滤自己墓地或除外状态下、除「星辰的吼炎」以外的「星辰」卡片的条件函数
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c9) and c:IsAbleToDeck()
end
-- 效果发动的实际处理（Operation）函数，执行无效化魔法卡以及后续的回收抽卡处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与对象卡片相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 立即刷新场上卡片的无效状态
		Duel.AdjustInstantly()
		-- 检查自己的墓地或除外状态是否存在符合条件的「星辰」卡片（受王家之谷影响）
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
			-- 检查玩家是否可以抽卡
			and Duel.IsPlayerCanDraw(tp,1)
			-- 询问玩家是否选择适用后续的回收并抽卡效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
			-- 提示玩家选择要返回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 玩家选择1张自己墓地或除外状态的「星辰」卡片
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
			local dtc=sg:GetFirst()
			if dtc then
				-- 插入效果处理间隔，使后续的回收卡组处理与前面的无效化处理不视为同时进行
				Duel.BreakEffect()
				-- 确认并向双方玩家展示所选的卡片
				Duel.HintSelection(sg)
				-- 将选择的卡片送回持有者卡组最下面，并确认其已成功回到卡组或额外卡组
				if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
					-- 插入效果处理间隔，使后续的抽卡处理与前面的回收卡组处理不视为同时进行
					Duel.BreakEffect()
					-- 玩家从卡组抽1张卡
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
