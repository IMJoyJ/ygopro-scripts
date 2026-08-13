--蟲惑の誘い
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡从手卡丢弃才能发动。自己从卡组抽2张。
-- ②：把墓地的这张卡除外，以除外的自己1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡为对象才能发动。那张卡回到卡组最下面。
local s,id,o=GetID()
-- 注册虫惑的引诱的两个效果：e1为①效果（发动时丢弃手卡并从卡组抽2张），e2为②效果（从墓地除外自身，以除外区的对象卡为对象返回卡组最下面）。
function s.initial_effect(c)
	-- ①：把1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡从手卡丢弃才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的自己1只昆虫族·植物族的4星怪兽或者1张通常陷阱卡为对象才能发动。那张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果发动时的代价：通过 aux.bfgcost 将墓地中的此卡除外作为cost。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断一张卡是否为昆虫族·植物族的4星怪兽，或者是否为通常陷阱卡（逻辑等价于 (昆虫/植物且4星) 或 通常陷阱）。
function s.filter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsLevel(4) or c:GetType()==TYPE_TRAP
end
-- 用于①效果cost的过滤：该卡必须能够从手卡丢弃，并且满足 s.filter 的种族/等级/卡种条件。
function s.cfilter(c)
	return c:IsDiscardable() and s.filter(c)
end
-- ①效果的代价函数：检查手卡中是否存在1张可丢弃且符合条件的卡；若存在，发动时玩家从手卡丢弃1张满足条件的卡作为代价，丢弃原因同时包含COST和DISCARD。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己手卡中是否存在至少1张满足 s.cfilter（可丢弃且符合条件）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：玩家tp从手卡选择并丢弃1张满足 s.cfilter 的卡，丢弃原因设为代价+丢弃。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动目标设定：该效果以玩家自身为对象，设定抽卡玩家为自己、抽卡数为2，并设置对应的抽卡操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认玩家tp当前可以进行抽卡，且抽卡数量为2时允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的目标玩家设置为tp，表示该效果作用的目标玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为2，表示效果处理时要抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置抽卡的操作信息：类别为CATEGORY_DRAW，目标玩家为tp，数量为2，用于其他卡的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ①效果的处理函数：从连锁信息中取出目标玩家和抽卡数量，让该玩家执行抽卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和目标参数，分别存入变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②效果对象过滤：判断卡是否为表侧表示、能否返回卡组，并且满足 s.filter 的条件（昆虫/植物4星或通常陷阱）。
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck() and s.filter(c)
end
-- ②效果的目标选择函数：允许指定之前已连锁选择的对象；进行合法性检查后，显示选择提示，并从自己除外区选择1张符合条件的表侧卡作为效果对象，同时设置回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 合法性检查：确认自己除外区是否存在至少1张表侧表示且可回卡组并且满足 s.filter 的卡，可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 弹出选择提示消息，提示玩家选择要返回卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从玩家tp的除外区选择1张满足 s.tdfilter 的表侧卡作为效果对象，并自动与当前连锁建立对象联系。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置回卡组的操作信息：对象为选中的卡组g，数量为1，表示处理时将其返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果的处理函数：取得对象卡，若对象仍与效果关联，则将其返回持有者卡组最下面。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡（即②效果选择的那张除外区的卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送入其持有者的卡组最底端（SEQ_DECKBOTTOM），原因为效果。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
