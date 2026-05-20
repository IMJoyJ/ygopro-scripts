--不知火流 輪廻の陣
-- 效果：
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「不知火流 转生之阵」使用。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●把自己场上1只表侧表示的不死族怪兽除外才能发动。这个回合，自己受到的全部伤害变成0。
-- ●以除外的2只自己的守备力0的不死族怪兽为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
function c78765160.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 使这张卡在魔法与陷阱区域存在时，卡名当作「不知火流 转生之阵」使用。
	aux.EnableChangeCode(c,40005099)
	-- ●把自己场上1只表侧表示的不死族怪兽除外才能发动。这个回合，自己受到的全部伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78765160,0))  --"除外并使伤害变成0"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCost(c78765160.damcost)
	e3:SetOperation(c78765160.damop)
	c:RegisterEffect(e3)
	-- ●以除外的2只自己的守备力0的不死族怪兽为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(78765160,1))  --"回收并抽卡"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetTarget(c78765160.tdtg)
	e4:SetOperation(c78765160.tdop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示、可以作为发动代价除外的不死族怪兽。
function c78765160.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 伤害变0效果的发动代价（Cost）处理函数。
function c78765160.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c78765160.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送选择要除外的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只满足条件的不死族怪兽。
	local g=Duel.SelectMatchingCard(tp,c78765160.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 伤害变0效果的效果处理（Operation）函数。
function c78765160.damop(e,tp,eg,ep,ev,re,r,rp)
	-- ●以除外的2只自己的守备力0的不死族怪兽为对象才能发动。那2只怪兽回到卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使自己受到的全部战斗伤害变成0的全局效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使自己受到的全部效果伤害变成0的全局效果。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：除外的、守备力为0且可以回到卡组的自己不死族怪兽。
function c78765160.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsAbleToDeck()
end
-- 回收并抽卡效果的发动准备（Target）函数。
function c78765160.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c78765160.tdfilter(chkc) end
	-- 检查自己当前是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且检查除外区域是否存在至少2只满足条件的自己不死族怪兽。
		and Duel.IsExistingTarget(c78765160.tdfilter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 给玩家发送选择要返回卡组的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外的2只满足条件的自己不死族怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c78765160.tdfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置当前连锁的操作信息，表明此效果包含将这2张卡送回卡组的处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置当前连锁的操作信息，表明此效果包含让玩家抽1张卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 回收并抽卡效果的效果处理（Operation）函数。
function c78765160.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not e:GetHandler():IsRelateToEffect(e) or not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将作为对象的怪兽送回持有者卡组并洗切。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 如果实际有卡片回到了主卡组，则洗切自己的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==2 then
		-- 中断当前效果，使后续的抽卡处理与回卡组处理不视为同时进行。
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
