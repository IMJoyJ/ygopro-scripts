--星辰の裂角
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只攻击表示怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。那之后，以下效果可以适用。
-- ●「星辰的裂角」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：以场上1只攻击表示怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。那之后，以下效果可以适用。●「星辰的裂角」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
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
-- 过滤场上攻击表示且能回到手牌的怪兽
function s.rthfilter(c)
	return c:IsPosition(POS_ATTACK) and c:IsAbleToHand()
end
-- 效果①的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rthfilter(chkc) end
	-- 在发动时判断场上是否存在满足条件的攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上一只攻击表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选中的对象怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤自己墓地或除外状态中，除了「星辰的裂角」之外且可以回到卡组的「星辰」卡
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c9) and c:IsAbleToDeck()
end
-- 效果①的生效处理，将对象怪兽返回手牌，并根据玩家的选择执行后续回收及抽卡效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，且为怪兽卡，并尝试将其返回手牌
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 检查自己墓地及除外状态中是否存在可回收的「星辰」卡
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 检查玩家是否可以抽卡，并询问玩家是否选择适用回收并抽卡的效果
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己墓地或除外状态选择1张要返回卡组的「星辰」卡
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		local dtc=sg:GetFirst()
		if dtc then
			-- 中断效果，使后续的回收与抽卡效果视为不同时处理
			Duel.BreakEffect()
			-- 手动显示所选卡片的动画效果
			Duel.HintSelection(sg)
			-- 将选择的「星辰」卡送回卡组最下面，并检查是否操作成功
			if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
				-- 中断效果，使后续的抽卡效果视为不同时处理
				Duel.BreakEffect()
				-- 玩家从卡组抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
