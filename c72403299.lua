--リチュア・ディバイナー
-- 效果：
-- 1回合1次，宣言1个卡名才能发动。把自己卡组最上面的卡翻开，那是宣言的卡的场合加入手卡。不是的场合，回到自己卡组最上面。
function c72403299.initial_effect(c)
	-- 1回合1次，宣言1个卡名才能发动。把自己卡组最上面的卡翻开，那是宣言的卡的场合加入手卡。不是的场合，回到自己卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72403299,0))  --"宣言卡名"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c72403299.target)
	e1:SetOperation(c72403299.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标与宣言处理：检查卡组是否有卡可加入手卡，并让发动玩家宣言一个卡名。
function c72403299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在至少1张可以加入手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名（过滤掉融合、同调、超量、连接等额外怪兽类型）。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名作为当前连锁的目标参数保存。
	Duel.SetTargetParam(ac)
	-- 设置效果处理信息为宣言卡名。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理：翻开卡组最上方的卡，若与宣言的卡名相同则加入手卡，否则放回卡组最上面。
function c72403299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组没有卡，则不进行处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 确认（翻开）自己卡组最上方的一张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的一张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 获取发动时宣言的卡名参数。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 禁用接下来的洗牌检测，防止卡片加入手卡时自动洗切卡组。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡片加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 手动洗切手卡。
		Duel.ShuffleHand(tp)
	end
end
