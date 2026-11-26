--トライブ・ドライブ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽的种族是3种类以上的场合才能发动。和自己场上的怪兽相同种族的怪兽从卡组选3只（相同种族最多1只）。对方从那之中随机选1只，自己把那只怪兽加入手卡或特殊召唤。剩下的怪兽用喜欢的顺序回到卡组下面。
function c90969892.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽的种族是3种类以上的场合才能发动。和自己场上的怪兽相同种族的怪兽从卡组选3只（相同种族最多1只）。对方从那之中随机选1只，自己把那只怪兽加入手卡或特殊召唤。剩下的怪兽用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90969892+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c90969892.target)
	e1:SetOperation(c90969892.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为与指定种族一致、且可加入手卡或特殊召唤的怪兽。
function c90969892.filter(c,e,tp,race)
	return c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:IsRace(race)
end
-- ①效果的目标处理函数：统计自己场上表侧怪兽的种族集合及数量，检查自己场上种族达3种以上且卡组能选出3只不同种族的对应怪兽。
function c90969892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示的怪兽卡片组。
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct1=mg:GetClassCount(Card.GetRace)
	local mc=mg:GetFirst()
	local mrc=0
	while mc do
		mrc=mrc|mc:GetRace()
		mc=mg:GetNext()
	end
	-- 从自己卡组获取所有属于场上怪兽种族且可加入手卡或特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(c90969892.filter,tp,LOCATION_DECK,0,nil,e,tp,mrc)
	local ct2=g:GetClassCount(Card.GetRace)
	-- 发动条件检查：确认场上怪兽种族不少于3种、卡组可用怪兽种族不少于3种且存在3只不同种族的组合。
	if chk==0 then return ct1>=3 and ct2>=3 and g:CheckSubGroup(aux.drccheck,3,3) end
end
-- ①效果的处理函数：从卡组选3只不同种族怪兽给对方确认，对方随机选1只由己方加入手卡或特殊召唤，剩余2只排序后回到卡组最下面。
function c90969892.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽卡片组。
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct1=mg:GetClassCount(Card.GetRace)
	local mc=mg:GetFirst()
	local mrc=0
	while mc do
		mrc=mrc|mc:GetRace()
		mc=mg:GetNext()
	end
	-- 从自己卡组获取所有属于场上怪兽种族且可加入手卡或特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(c90969892.filter,tp,LOCATION_DECK,0,nil,e,tp,mrc)
	local ct2=g:GetClassCount(Card.GetRace)
	if ct1<3 or ct2<3 then return end
	-- 发送提示信息，引导玩家选择给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从卡组符合条件的怪兽中选择3只互不相同种族的怪兽。
	local sg=g:SelectSubGroup(tp,aux.drccheck,false,3,3)
	if sg then
		-- 将选出的3只怪兽展示给对方确认。
		Duel.ConfirmCards(1-tp,sg)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方随机选出的那1只怪兽展示给己方确认。
		Duel.ConfirmCards(tp,tc)
		-- 检查自己怪兽区是否有空位且该怪兽能否被特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 让己方选择是否将该怪兽特殊召唤（1为特殊召唤，0为加入手卡）。
			and Duel.SelectOption(tp,1190,1152)==1 then
			-- 将对方随机选出的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将对方随机选出的怪兽以效果加入自己手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
		sg:RemoveCard(tc)
		-- 手动洗切己方的卡组。
		Duel.ShuffleDeck(tp)
		-- 将剩余2只中的第1只临时移至卡组最上面准备排序。
		Duel.MoveSequence(sg:GetFirst(),SEQ_DECKTOP)
		-- 将剩余2只中的第2只临时移至卡组最上面准备排序。
		Duel.MoveSequence(sg:GetNext(),SEQ_DECKTOP)
		-- 让己方对卡组最上方的这2张怪兽进行排序。
		Duel.SortDecktop(tp,tp,2)
		for i=1,2 do
			-- 循环获取当前位于卡组最上方的1张卡。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到自己卡组的最下面。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
