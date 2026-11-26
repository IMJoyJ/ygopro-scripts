--真実の名
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。并且，可以再从卡组把1只神属性怪兽加入手卡或特殊召唤。不是的场合，翻开的卡送去墓地。
function c39913299.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。并且，可以再从卡组把1只神属性怪兽加入手卡或特殊召唤。不是的场合，翻开的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39913299+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c39913299.target)
	e1:SetOperation(c39913299.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为可加入手卡或（在有空位时）可特殊召唤的神属性怪兽。
function c39913299.filter(c,e,tp)
	-- 判断卡片是否为神属性且能够加入手卡或在自己怪兽区有空位时可特殊召唤。
	return c:IsAttribute(ATTRIBUTE_DIVINE) and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的目标处理函数：检查卡组丢弃与检索合法性，让玩家宣言1个卡名并记录宣言参数。
function c39913299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方玩家能够将卡组最上面1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 确认自己卡组存在至少1张可以加入手卡的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 发送提示信息，引导玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让己方玩家根据过滤规则（排除额外卡组怪兽）宣言1个卡名并保存卡号。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将玩家宣言的卡号设为当前连锁的目标参数。
	Duel.SetTargetParam(ac)
	-- 设置操作信息：本次效果包含宣言卡名的操作。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- ①效果的处理函数：翻开卡组最上方1张卡，若为宣言的卡则加入手卡并可选检索或特招1只神属性怪兽，否则送去墓地。
function c39913299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组是否仍有卡片，若卡组为空则结束处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	-- 向双方翻开确认自己卡组最上方1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方1张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 从当前连锁信息中读取发动时宣言的卡号。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 将翻开的且符合宣言卡名的卡以效果加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 获取自己卡组中所有符合条件（可加入手卡或特招）的神属性怪兽卡片组。
		local g=Duel.GetMatchingGroup(c39913299.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可用神属性怪兽，询问玩家是否将其加入手卡或特殊召唤。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39913299,0)) then  --"是否把神属性怪兽加入手卡或特殊召唤？"
			-- 中断当前效果处理，使之后的神属性怪兽处理与之前的加手卡视为不同时处理。
			Duel.BreakEffect()
			-- 发送提示信息，引导玩家选择要操作的神属性怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			local b1=sc:IsAbleToHand()
			-- 检查自己怪兽区是否有空位且所选神属性怪兽能否被特殊召唤。
			local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local op=0
			-- 若所选神属性怪兽既能加入手卡也能特殊召唤，让玩家选择加入手卡还是特殊召唤。
			if b1 and b2 then op=Duel.SelectOption(tp,1190,1152)
			elseif b1 then op=0
			else op=1 end
			if op==0 then
				-- 将所选神属性怪兽以效果加入手卡。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 将加入手卡的神属性怪兽展示给对方确认。
				Duel.ConfirmCards(1-tp,sc)
			else
				-- 将所选神属性怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 若不进行神属性怪兽检索或特招，则禁用接下来的洗卡检测以保持原卡组顺序。
			Duel.DisableShuffleCheck()
		end
		-- 手动洗切己方的手卡。
		Duel.ShuffleHand(tp)
	else
		-- 翻开的卡不是宣言的卡时，禁用洗卡检测以避免误洗切卡组。
		Duel.DisableShuffleCheck()
		-- 将翻开的不符合宣言卡名的卡以翻开送墓的原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
