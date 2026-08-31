--信用取引
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方可以丢弃1张手卡让这个效果无效。没丢弃的场合，双方玩家各自把对方卡组确认，从那之中选1张卡。那之后，双方玩家各自把对方选的卡加入手卡。
function c62632427.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方可以丢弃1张手卡让这个效果无效。没丢弃的场合，双方玩家各自把对方卡组确认，从那之中选1张卡。那之后，双方玩家各自把对方选的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62632427,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62632427+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c62632427.target)
	e1:SetOperation(c62632427.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：可以加入手卡的卡
function c62632427.filter(c,p)
	return c:IsAbleToHand(p)
end
-- 发动条件与操作信息
function c62632427.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组是否存在可以加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62632427.filter,tp,LOCATION_DECK,0,1,nil,tp)
		-- 且对方卡组是否存在可以加入手卡的卡
		and Duel.IsExistingMatchingCard(c62632427.filter,tp,0,LOCATION_DECK,1,nil,1-tp) end
	-- 设置操作信息：双方各自从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,PLAYER_ALL,LOCATION_DECK)
end
-- 效果处理函数
function c62632427.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方是否有手卡且效果能否被无效
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsChainDisablable(0)
		-- 对方选择是否丢弃1张手卡使效果无效
		and Duel.SelectYesNo(1-tp,aux.Stringid(62632427,1)) then  --"是否丢弃1张手卡把「信用取引」无效？"
		-- 对方丢弃1张手卡
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		-- 使效果无效
		Duel.NegateEffect(0)
		return
	end
	-- 获取自己卡组的全部卡
	local d1=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	-- 获取对方卡组的全部卡
	local d2=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	if #d1==0 or #d2==0 then return end
	-- 自己确认对方卡组
	Duel.ConfirmCards(tp,d2)
	-- 对方确认自己卡组
	Duel.ConfirmCards(1-tp,d1)
	-- 提示自己从对方卡组选1张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62632427,2))  --"请选择要给对方加入手卡的卡"
	-- 从对方卡组选择1张卡
	local g2=Duel.SelectMatchingCard(tp,c62632427.filter,tp,0,LOCATION_DECK,1,1,nil,1-tp)
	-- 提示对方从自己卡组选1张卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(62632427,2))  --"请选择要给对方加入手卡的卡"
	-- 对方从自己卡组选择1张卡
	local g1=Duel.SelectMatchingCard(1-tp,c62632427.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 中断效果处理
	Duel.BreakEffect()
	-- 将自己选的对方卡组的卡加入对方手卡
	Duel.SendtoHand(g2,nil,REASON_EFFECT,1-tp)
	-- 向自己确认对方加入手卡的卡
	Duel.ConfirmCards(tp,g2)
	-- 将对方选的自己卡组的卡加入自己手卡
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 向对方确认自己加入手卡的卡
	Duel.ConfirmCards(1-tp,g1)
end
