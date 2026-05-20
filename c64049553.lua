--RR－ルースト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「急袭猛禽」怪兽从额外卡组往自己场上特殊召唤的场合才能发动。从卡组把「急袭猛禽-鸟窝」以外的1张「急袭猛禽」魔法·陷阱卡加入手卡。
-- ②：以自己的墓地·除外状态的3只「急袭猛禽」怪兽为对象才能发动。那些怪兽用喜欢的顺序回到卡组下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动、①效果和②效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：「急袭猛禽」怪兽从额外卡组往自己场上特殊召唤的场合才能发动。从卡组把「急袭猛禽-鸟窝」以外的1张「急袭猛禽」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：以自己的墓地·除外状态的3只「急袭猛禽」怪兽为对象才能发动。那些怪兽用喜欢的顺序回到卡组下面。那之后，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回收"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中「急袭猛禽-鸟窝」以外的「急袭猛禽」魔法·陷阱卡，且能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 过滤条件：从额外卡组特殊召唤到自己场上的「急袭猛禽」怪兽。
function s.cfilter(c,tp)
	return c:IsSetCard(0xba) and c:IsControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①效果的发动准备与合法性检测，若可行则设置检索并加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否有满足条件的「急袭猛禽」怪兽从额外卡组特殊召唤，且自己卡组中存在可检索的「急袭猛禽」魔陷。
		return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张满足条件的「急袭猛禽」魔陷加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己墓地或除外状态的「急袭猛禽」怪兽，且能回到卡组。
function s.tdfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsFaceupEx()
end
-- ②效果的发动准备与合法性检测，包括判断是否能成为效果对象以及玩家是否能抽卡。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查玩家当前是否可以因效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己的墓地或除外状态是否存在至少3只满足条件的「急袭猛禽」怪兽可以作为对象。
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择3只目标怪兽并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	-- 设置连锁处理的操作信息：将选中的对象卡片送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁处理的操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：将作为对象的怪兽用喜欢的顺序回到卡组下面，成功回到卡组后自己抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果关联的对象卡片集合。
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 让玩家将这些卡以任意顺序放回卡组最下方。
	aux.PlaceCardsOnDeckBottom(tp,sg)
	-- 获取上一步操作中实际移动位置的卡片集合。
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续的抽卡处理与放回卡组不视为同时进行。
		Duel.BreakEffect()
		-- 玩家因效果抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
