--星辰の裂角
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只攻击表示怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。那之后，以下效果可以适用。
-- ●「星辰的裂角」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片发动时的效果：1回合只能发动1张，以场上1只攻击表示怪兽为对象，具有回手、回卡组、回额外、抽卡、墓地动作等效果分类，自由时点发动。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1只攻击表示怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。那之后，以下效果可以适用。●「星辰的裂角」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_TOEXTRA+CATEGORY_DRAW+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上的攻击表示且能回到手卡的怪兽。
function s.rthfilter(c)
	return c:IsPosition(POS_ATTACK) and c:IsAbleToHand()
end
-- 效果发动的对象选择与准备：检查并选择场上1只攻击表示怪兽作为对象，并设置操作信息为回手。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rthfilter(chkc) end
	-- 检查场上是否存在至少1只满足条件的攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的对象怪兽送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤条件：自己墓地或除外状态的、除「星辰的裂角」以外的「星辰」卡片，且能回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c9) and c:IsAbleToDeck()
end
-- 效果处理：将对象怪兽送回手卡，之后可选择将墓地或除外的1张「星辰」卡回到卡组最下面并抽1张卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在且符合条件，则将其送回持有者的手卡（或额外卡组）。
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 检查自己的墓地或除外状态是否存在满足条件的「星辰」卡（受王家长眠之谷影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 检查玩家是否可以抽卡，并询问玩家是否适用后续的回收并抽卡效果。
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
		-- 提示玩家选择要返回卡组的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 玩家从墓地或除外状态选择1张满足条件的「星辰」卡。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		local dtc=sg:GetFirst()
		if dtc then
			-- 中断当前效果，使后续的回收卡组处理与前面的回手处理不视为同时进行。
			Duel.BreakEffect()
			-- 显式示出被选中的卡片。
			Duel.HintSelection(sg)
			-- 将选中的卡片回到卡组最下面，并确认是否成功回到卡组或额外卡组。
			if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
				-- 中断当前效果，使后续的抽卡处理与前面的回到卡组处理不视为同时进行。
				Duel.BreakEffect()
				-- 玩家从卡组抽1张卡。
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
