--切り盛り隊長
-- 效果：
-- ①：这张卡召唤成功时才能发动。让1张手卡回到卡组洗切。那之后，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽特殊召唤。
function c48737767.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。让1张手卡回到卡组洗切。那之后，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48737767,0))  --"手卡回到卡组"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c48737767.target)
	e1:SetOperation(c48737767.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查玩家是否可以抽卡且手牌中是否存在可送回卡组的卡片
function c48737767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果作用：检查手牌中是否存在至少1张可送回卡组的卡片
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：设置将要送回卡组的卡片数量为1
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 效果作用：设置将要抽卡的数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果原文内容：让1张手卡回到卡组洗切。那之后，自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以把那只怪兽特殊召唤。
function c48737767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择1张手牌送回卡组
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：判断是否成功将卡片送回卡组并洗切
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 效果作用：洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 效果作用：中断当前连锁处理
		Duel.BreakEffect()
		-- 效果作用：让玩家从卡组抽1张卡
		if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
		-- 效果作用：获取上一次操作实际处理的卡片组
		local dg=Duel.GetOperatedGroup()
		local dc=dg:GetFirst()
		-- 效果作用：判断场上是否有空位且该卡是否可以特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and dc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 效果作用：询问玩家是否要特殊召唤该卡
			and Duel.SelectYesNo(tp,aux.Stringid(48737767,1)) then  --"是否特殊召唤？"
			-- 效果作用：将该卡特殊召唤到场上
			Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
