--切り盛り隊長
-- 效果：
-- ①：这张卡召唤成功时才能发动。让1张手卡回到卡组洗切。那之后，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽特殊召唤。
function c48737767.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。让1张手卡回到卡组洗切。那之后，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48737767,0))  --"手卡回到卡组"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c48737767.target)
	e1:SetOperation(c48737767.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动条件检测：确认玩家tp可以抽1张卡，并且手牌中存在可返回卡组的卡时才可发动。
function c48737767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测tp是否能够进行1张抽卡，作为发动条件之一。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检测tp手牌中是否存在至少1张可以返回卡组的卡，作为发动条件之一。
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：预告效果将把tp手牌的1张卡返回卡组（不取对象，指定位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：预告效果将让tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理整体：选择1张手卡返回卡组并洗切，然后抽1张卡；若抽到的是怪兽且满足条件，则询问是否将其特殊召唤。
function c48737767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向tp显示选择提示，提示选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让tp从手牌中选择1张可以返回卡组的卡，返回所选卡组对象g。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	-- 若成功选择了卡且将其以洗切方式返回卡组，则继续后续处理。
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 洗切tp的卡组。
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理，使后续处理视为不同时点，避免错失时点。
		Duel.BreakEffect()
		-- 让tp抽1张卡；若未能抽卡（如卡组为空）则终止处理。
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 获取上一次操作（抽卡）实际操作到的卡组对象，即抽到的那张卡。
		local dg=Duel.GetOperatedGroup()
		local dc=dg:GetFirst()
		-- 检查tp主要怪兽区是否有空位，且抽到的卡是否能够被当前效果特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and dc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问tp是否选择将那只怪兽特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(48737767,1)) then  --"是否特殊召唤？"
			-- 将抽到的怪兽以表侧攻击表示特殊召唤到tp场上。
			Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
