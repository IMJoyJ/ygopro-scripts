--Nouvellez Auberge 『À Table』
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地选1张「食谱」卡加入手卡。
-- ②：1回合1次，从手卡让1只仪式怪兽回到卡组最下面才能发动。自己从卡组抽1张。
-- ③：自己结束阶段，以包含「食谱」卡的自己墓地2张卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己从卡组抽1张。
local s,id,o=GetID()
-- 定义卡片的初始效果函数：创建并注册三个效果——①发动时从卡组·墓地检索「食谱」加入手卡；②丢弃手牌仪式怪兽回卡组底抽1张；③结束阶段选墓地2张卡回卡组底后抽1张，分别对应魔法卡发动、起动效果、诱发效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地选1张「食谱」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡让1只仪式怪兽回到卡组最下面才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.drcost1)
	e2:SetTarget(s.drtg1)
	e2:SetOperation(s.drop1)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段，以包含「食谱」卡的自己墓地2张卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.drcon2)
	e3:SetTarget(s.drtg2)
	e3:SetOperation(s.drop2)
	c:RegisterEffect(e3)
end
-- 定义「食谱」卡的检索过滤条件：卡名属于「食谱」系列（set=0x197），且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x197) and c:IsAbleToHand()
end
-- 处理①效果：若自己卡组·墓地存在满足条件的「食谱」卡，经玩家确认后选1张加入手卡，并向对方展示。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组·墓地里满足thfilter条件且不受「王家长眠之谷」影响的「食谱」卡集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 若存在可检索的「食谱」卡，且玩家选择发动（选择是），则继续执行检索处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选1张「食谱」卡加入手卡？"
		-- 给予玩家选择要加入手牌的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「食谱」卡以效果原因加入其持有者手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义②效果的cost过滤器：手卡中的仪式怪兽（类型含TYPE_RITUAL），且可以作为cost返回卡组。
function s.costfilter(c)
	return c:GetType()&0x81==0x81 and c:IsAbleToDeckAsCost()
end
-- 处理②效果的发动cost：从手卡选择1只仪式怪兽返回卡组最下面，并让对方确认。
function s.drcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：手卡是否存在至少1只符合条件的仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给予玩家选择要返回卡组的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从手卡选择1只仪式怪兽作为发动②效果的cost。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方展示作为cost返回卡组的仪式怪兽。
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的仪式怪兽以cost原因返回持有者卡组最下面（SEQ_DECKBOTTOM）。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 设定②效果的目标：检查自己能否抽1张卡，并记录抽卡玩家与抽卡数量等信息。
function s.drtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡，若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，以记录抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记本次效果操作包含抽1张卡，供后续效果处理或卡片联动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理②效果的抽卡部分：按连锁记录的对象玩家和抽卡数量执行抽卡。
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象玩家和抽卡数量（分别为p和d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让p玩家抽d张卡（此处为自己抽1张），原因为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：仅在自己回合的结束阶段可以发动。
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是自己，确保在自己结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 定义③效果对象的选择条件：该卡是「食谱」卡且能返回卡组，同时墓地还存在另一张可返回卡组的卡，以保证可选满2张。
function s.tdfilter(c,tp)
	return c:IsSetCard(0x197) and c:IsAbleToDeck()
		-- 检查墓地是否存在除当前卡以外至少1张可返回卡组的卡，用于满足选2张对象的要求。
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,c)
end
-- ③效果的发动条件检查：自己可抽1张，且墓地存在满足tdfilter条件的对象（含「食谱」卡的2张可回卡组组合）。
function s.drtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己是否可以抽1张卡，用于发动条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查墓地是否存在至少1组由1张「食谱」卡和另1张可返回卡组的卡构成的对象组合。
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 给予玩家选择要返回卡组的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张「食谱」卡作为返回卡组的对象（取对象），该卡需满足tdfilter，保证墓地还能再选1张可回卡组的卡。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 再次给予玩家选择要返回卡组的第二张卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择另1张可返回卡组的卡作为第二个对象，且不能与第一张重复（exclude g）。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,g)
	g:Merge(g2)
	-- 登记本次效果操作包含将2张对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 登记本次效果操作包含抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理③效果：将取对象的2张卡按玩家选择的顺序放回卡组底端，若成功放置则再抽1张卡。
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中仍与效果相关的2张对象卡（若对象卡已离场或不受影响则不会包含在内）。
	local g=Duel.GetTargetsRelateToChain()
	-- 若没有可处理的对象卡，或无法将对象卡放回卡组底端，则效果处理中止；否则继续抽卡。
	if #g==0 or aux.PlaceCardsOnDeckBottom(tp,g)==0 then return end
	-- 使用Duel.BreakEffect中断当前效果，使后续抽卡作为独立连锁处理，避免错过时点。
	Duel.BreakEffect()
	-- 自己抽1张卡，完成③效果。
	Duel.Draw(tp,1,REASON_EFFECT)
end
