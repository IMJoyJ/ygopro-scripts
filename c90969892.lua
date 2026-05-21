--トライブ・ドライブ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽的种族是3种类以上的场合才能发动。和自己场上的怪兽相同种族的怪兽从卡组选3只（相同种族最多1只）。对方从那之中随机选1只，自己把那只怪兽加入手卡或特殊召唤。剩下的怪兽用喜欢的顺序回到卡组下面。
function c90969892.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽的种族是3种类以上的场合才能发动。和自己场上的怪兽相同种族的怪兽从卡组选3只（相同种族最多1只）。对方从那之中随机选1只，自己把那只怪兽加入手卡或特殊召唤。剩下的怪兽用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90969892+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c90969892.target)
	e1:SetOperation(c90969892.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中与自己场上怪兽相同种族、且可以加入手卡或特殊召唤的怪兽
function c90969892.filter(c,e,tp,race)
	return c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:IsRace(race)
end
-- 效果发动时的目标检查函数，确认自己场上怪兽种族数是否在3种以上，且卡组中存在3只种族互不相同、但与场上怪兽种族相同的可检索或特召怪兽
function c90969892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示的怪兽
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct1=mg:GetClassCount(Card.GetRace)
	local mc=mg:GetFirst()
	local mrc=0
	while mc do
		mrc=mrc|mc:GetRace()
		mc=mg:GetNext()
	end
	-- 从卡组中筛选出与自己场上怪兽相同种族，且可以加入手卡或特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c90969892.filter,tp,LOCATION_DECK,0,nil,e,tp,mrc)
	local ct2=g:GetClassCount(Card.GetRace)
	-- 检查自己场上怪兽种族是否在3种以上，且卡组中是否存在3只种族互不相同的符合条件的怪兽
	if chk==0 then return ct1>=3 and ct2>=3 and g:CheckSubGroup(aux.drccheck,3,3) end
end
-- 效果处理函数，执行选卡、对方随机选择、加入手卡或特殊召唤、以及余下卡片放回卡组底部的处理
function c90969892.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct1=mg:GetClassCount(Card.GetRace)
	local mc=mg:GetFirst()
	local mrc=0
	while mc do
		mrc=mrc|mc:GetRace()
		mc=mg:GetNext()
	end
	-- 从卡组中筛选出与自己场上怪兽相同种族，且可以加入手卡或特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c90969892.filter,tp,LOCATION_DECK,0,nil,e,tp,mrc)
	local ct2=g:GetClassCount(Card.GetRace)
	if ct1<3 or ct2<3 then return end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从卡组中选择3只种族互不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.drccheck,false,3,3)
	if sg then
		-- 将选出的3只怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方随机选出的那张卡给己方玩家确认
		Duel.ConfirmCards(tp,tc)
		-- 检查自己场上是否有空余的怪兽区域，且该怪兽是否可以特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 让玩家选择加入手卡或特殊召唤，并判断是否选择特殊召唤（1190为加入手卡，1152为特殊召唤）
			and Duel.SelectOption(tp,1190,1152)==1 then
			-- 将该怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将该怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
		sg:RemoveCard(tc)
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
		-- 将剩下的第一张怪兽移动到卡组最上方
		Duel.MoveSequence(sg:GetFirst(),SEQ_DECKTOP)
		-- 将剩下的第二张怪兽移动到卡组最上方
		Duel.MoveSequence(sg:GetNext(),SEQ_DECKTOP)
		-- 让玩家对卡组最上方的2张卡（即剩下的2只怪兽）按喜欢的顺序进行排序
		Duel.SortDecktop(tp,tp,2)
		for i=1,2 do
			-- 获取卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方（通过循环将排序后的2张卡依次放回卡组最下方）
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
