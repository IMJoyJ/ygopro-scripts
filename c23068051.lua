--幽麗なる幻滝
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只幻龙族怪兽加入手卡。
-- ●从手卡以及自己场上的表侧表示怪兽之中把幻龙族怪兽任意数量送去墓地才能发动。自己从卡组抽出送去墓地的怪兽的数量＋1张。
function c23068051.initial_effect(c)
	-- 从卡组把1只幻龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23068051,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c23068051.target)
	e1:SetOperation(c23068051.activate)
	c:RegisterEffect(e1)
	-- 从手卡以及自己场上的表侧表示怪兽之中把幻龙族怪兽任意数量送去墓地才能发动。自己从卡组抽出送去墓地的怪兽的数量＋1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23068051,1))  --"送去墓地并抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(c23068051.cost)
	e2:SetTarget(c23068051.target2)
	e2:SetOperation(c23068051.activate2)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡组中的怪兽是否为幻龙族且可以加入手卡。
function c23068051.filter(c)
	return c:IsRace(RACE_WYRM) and c:IsAbleToHand()
end
-- 第一个效果的发动条件与操作信息设定：卡组存在符合条件的幻龙族怪兽才能发动，并设置从卡组将1张卡加入手卡的操作信息。
function c23068051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：我方卡组存在至少1只满足条件的幻龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23068051.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次效果将进行把1张卡从卡组加入手卡的处理，目标为我方卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 第一个效果的处理：从卡组选择1只符合条件的幻龙族怪兽加入手卡，并向对方展示。
function c23068051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1只符合条件的幻龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c23068051.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以效果方式加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断怪兽是否可作为cost送去墓地，要求在手牌或场上表侧表示，且是幻龙族怪兽。
function c23068051.filter2(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsRace(RACE_WYRM) and c:IsAbleToGraveAsCost()
end
-- 第二个效果的cost处理：从手牌以及自己场上的表侧表示怪兽中选择任意数量幻龙族怪兽送去墓地，并将抽卡张数（送墓数量+1）暂存到效果标签中。
function c23068051.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost发动条件判定：手牌或自己场上存在至少1只符合条件的幻龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23068051.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 取得我方卡组的现存卡数量，用于计算可选择作为cost的怪兽数量上限。
	local ft=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	-- 取得手牌以及自己场上表侧表示怪兽中所有符合条件的幻龙族怪兽。
	local g=Duel.GetMatchingGroup(c23068051.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	local ct=math.min(ft-1,g:GetCount()+1)
	local sg=g:Select(tp,1,ct,nil)
	e:SetLabel(sg:GetCount()+1)
	-- 将选择的幻龙族怪兽作为cost送去墓地。
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 第二个效果的发动目标设定：确认我方可以抽卡，并将抽卡玩家设为自己，抽卡数量设为cost阶段计算的送墓数量+1。
function c23068051.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：我方可以抽至少2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将效果的对象玩家设为我方，即由我方进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设为抽卡张数（cost阶段暂存的数量）。
	Duel.SetTargetParam(e:GetLabel())
	-- 设定操作信息：本次效果将进行抽卡，抽卡玩家为我方，抽卡数量为先前计算的张数。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 第二个效果的处理：根据设定的玩家和数量执行抽卡。
function c23068051.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出目标玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家抽取指定数量的卡，抽卡原因为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
