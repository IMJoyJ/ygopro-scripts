--真実の名
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。并且，可以再从卡组把1只神属性怪兽加入手卡或特殊召唤。不是的场合，翻开的卡送去墓地。
function c39913299.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。并且，可以再从卡组把1只神属性怪兽加入手卡或特殊召唤。不是的场合，翻开的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39913299+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c39913299.target)
	e1:SetOperation(c39913299.operation)
	c:RegisterEffect(e1)
end
-- 定义从卡组中筛选可追加处理的神属性怪兽的过滤函数：满足神属性，且能够加入手卡，或能够被特殊召唤。
function c39913299.filter(c,e,tp)
	-- 筛选条件：该卡为神属性，并且（能加入手卡，或主要怪兽区有空位且能被特殊召唤）。
	return c:IsAttribute(ATTRIBUTE_DIVINE) and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 发动时的目标处理：检查发动条件（卡组顶端可送去墓地且卡组有可加入手卡的卡），宣言一个卡名并记录，同时设置操作信息。
function c39913299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查之一：自己是否可以把卡组顶端1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 发动条件检查之二：自己卡组中是否存在至少1张可以被加入手卡的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家提示“请宣言一个卡名”，并将宣言选择的提示信息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名（过滤掉融合、同调、超量、连接怪兽），返回所宣言的卡号。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号存入当前连锁的目标参数，供效果处理时使用。
	Duel.SetTargetParam(ac)
	-- 设置操作信息：本次效果包含卡名宣言这一操作（CATEGORY_ANNOUNCE）。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理的主要流程：确认并翻开卡组顶端1张卡，若与宣言卡名一致则加入手卡，并可继续选择神属性怪兽加入手卡或特殊召唤；若不一致则将翻开的卡送去墓地，同时控制自动洗牌检测。
function c39913299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己卡组没有卡，则无法进行任何处理，直接终止效果处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	-- 向双方确认自己卡组最上方1张卡（展示该卡）。
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方1张卡的卡片对象，用于后续判断。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 从当前连锁信息中取出之前记录的宣言卡号。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 将翻开的卡加入其持有者的手卡（通过效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 从卡组中筛选出满足c39913299.filter条件的卡片组，即符合追加条件的神属性怪兽。
		local g=Duel.GetMatchingGroup(c39913299.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 如果卡组中存在符合条件的神属性怪兽且玩家选择“是”，则继续执行追加处理；否则跳过追加处理并关闭洗牌检测。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39913299,0)) then  --"是否把神属性怪兽加入手卡或特殊召唤？"
			-- 中断当前效果处理，使后续追加处理视为单独的效果处理时点（防止错时点）。
			Duel.BreakEffect()
			-- 给玩家提示“请选择要操作的卡”，并进入选择卡片界面。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			local b1=sc:IsAbleToHand()
			-- 判断该神属性怪兽是否满足特殊召唤条件：自己主要怪兽区有空位，且该卡可以被特殊召唤。
			local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local op=0
			-- 根据该怪兽能否加入手卡或特殊召唤的组合情况，让玩家选择执行方式（加入手卡或特殊召唤）。
			if b1 and b2 then op=Duel.SelectOption(tp,1190,1152)
			elseif b1 then op=0
			else op=1 end
			if op==0 then
				-- 将选择的神属性怪兽加入手卡。
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方玩家展示这张加入手卡的卡，以确认其信息。
				Duel.ConfirmCards(1-tp,sc)
			else
				-- 将选择的神属性怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 玩家决定不追加处理时，关闭系统的自动洗牌检测，因为只是翻开卡组顶端而未实际取出卡。
			Duel.DisableShuffleCheck()
		end
		-- 手动洗切自己的手卡，因为可能已将卡加入手卡，同时重置洗牌检测状态。
		Duel.ShuffleHand(tp)
	else
		-- 翻开的卡与宣言卡名不一致（或不能加入手卡）时，关闭自动洗牌检测，避免系统因翻开卡组顶端而自动洗切卡组。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地，原因包含效果处理以及因翻开而展示（REASON_REVEAL）。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
