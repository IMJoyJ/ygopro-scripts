--デーモンの宣告
-- 效果：
-- ①：1回合1次，支付500基本分，宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
function c22796548.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付500基本分，宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22796548,0))  --"宣言"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c22796548.cost)
	e2:SetTarget(c22796548.target)
	e2:SetOperation(c22796548.operation)
	c:RegisterEffect(e2)
end
-- 发动效果的代价：定义发动时需要支付500基本分作为代价，并在支付阶段实际扣除。
function c22796548.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检测阶段：确认玩家当前是否能够支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付阶段：扣除玩家500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 效果发动条件与宣言处理：检查能否将卡组顶端卡送去墓地且卡组存在可加入手卡的卡，满足后让玩家宣言1个卡名并保存宣言结果。
function c22796548.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检测：玩家必须能将卡组最上方1张卡送去墓地（因为翻开的卡若不是宣言卡则要送去墓地）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 条件检测：确保卡组中存在至少1张能够加入手卡的卡，保证宣言正确时加入手卡的操作可行。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送宣言卡名的选择提示，引导玩家进行卡名宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家实际宣言一个卡名，并返回所宣言卡片的卡号。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号保存为当前连锁的对象参数，供效果处理阶段取用。
	Duel.SetTargetParam(ac)
	-- 设置操作信息：声明本次连锁包含“宣言卡名”这一效果分类，以便其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理：翻开卡组最上方1张卡，若卡名与宣言一致则将其加入手卡，否则将其送去墓地。
function c22796548.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查：确认发动效果的这张卡仍与效果关联，且玩家仍可将卡组顶端卡送去墓地；否则效果不处理。
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认卡组最上方1张卡，向双方展示该卡。
	Duel.ConfirmDecktop(tp,1)
	-- 取得卡组最上方1张卡的组对象，用于后续处理。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 从当前连锁信息中取出之前宣言的卡号，用于比较。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 禁用下一次操作的自动洗牌检查（因为之后会手动洗牌，避免额外自动洗牌）。
		Duel.DisableShuffleCheck()
		-- 将宣言一致的卡组顶端卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 手动洗切玩家手卡，并重置洗牌检测状态。
		Duel.ShuffleHand(tp)
	else
		-- 禁用下一次操作的自动洗牌检查（避免处理结束时卡组被自动洗切）。
		Duel.DisableShuffleCheck()
		-- 将不是宣言卡的翻开卡以“效果”及“揭示”的原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
