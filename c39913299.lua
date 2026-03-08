--真実の名
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。并且，可以再从卡组把1只神属性怪兽加入手卡或特殊召唤。不是的场合，翻开的卡送去墓地。
function c39913299.initial_effect(c)
	-- ①：宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。并且，可以再从卡组把1只神属性怪兽加入手卡或特殊召唤。不是的场合，翻开的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39913299+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c39913299.target)
	e1:SetOperation(c39913299.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回满足条件的神属性怪兽（可以加入手卡或特殊召唤）
function c39913299.filter(c,e,tp)
	-- 返回满足条件的神属性怪兽（可以加入手卡或特殊召唤）
	return c:IsAttribute(ATTRIBUTE_DIVINE) and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果发动时的处理，检查是否满足发动条件
function c39913299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组顶端1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查玩家卡组中是否存在至少1张可以加入手卡的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名设置为连锁参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息，记录宣言的卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理时的处理，执行效果内容
function c39913299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家卡组是否为空
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	-- 确认玩家卡组最上方1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 获取连锁中记录的宣言卡名
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 将翻开的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 过滤出满足条件的神属性怪兽
		local g=Duel.GetMatchingGroup(c39913299.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断是否有神属性怪兽可操作并询问玩家是否操作
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39913299,0)) then  --"是否把神属性怪兽加入手卡或特殊召唤？"
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要操作的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			local b1=sc:IsAbleToHand()
			-- 判断目标神属性怪兽是否可以特殊召唤
			local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local op=0
			-- 根据可操作选项选择操作方式
			if b1 and b2 then op=Duel.SelectOption(tp,1190,1152)
			elseif b1 then op=0
			else op=1 end
			if op==0 then
				-- 将神属性怪兽加入手卡
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方确认该卡加入手卡
				Duel.ConfirmCards(1-tp,sc)
			else
				-- 将神属性怪兽特殊召唤到场上
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 禁止后续操作进行洗切卡组
			Duel.DisableShuffleCheck()
		end
		-- 洗切玩家手卡
		Duel.ShuffleHand(tp)
	else
		-- 禁止后续操作进行洗切卡组
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
