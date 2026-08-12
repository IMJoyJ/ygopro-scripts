--デーモンの宣告
-- 效果：
-- ①：1回合1次，支付500基本分，宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
function c22796548.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付500基本分，宣言1个卡名才能发动。
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
-- 支付500基本分
function c22796548.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 宣言1个卡名才能发动。自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
function c22796548.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能从卡组上面翻开一张卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查玩家的卡组中是否存在至少一张可以加入手卡的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示“请宣言一个卡名”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡号
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号设置为连锁的对象参数
	Duel.SetTargetParam(ac)
	-- 设置当前处理的连锁的操作信息为宣言卡牌
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 自己卡组最上面的卡翻开，宣言的卡的场合，那张卡加入手卡。不是的场合，翻开的卡送去墓地。
function c22796548.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否还在场上以及玩家是否能从卡组上面翻开一张卡
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认玩家卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 获取当前连锁的对象参数（即宣言的卡号）
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc:IsCode(ac) and tc:IsAbleToHand() then
		-- 禁止接下来的卡组操作进行洗切检测
		Duel.DisableShuffleCheck()
		-- 将目标卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 手动洗切玩家的手卡
		Duel.ShuffleHand(tp)
	else
		-- 禁止接下来的卡组操作进行洗切检测
		Duel.DisableShuffleCheck()
		-- 将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
