--幽麗なる幻滝
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只幻龙族怪兽加入手卡。
-- ●从手卡以及自己场上的表侧表示怪兽之中把幻龙族怪兽任意数量送去墓地才能发动。自己从卡组抽出送去墓地的怪兽的数量＋1张。
function c23068051.initial_effect(c)
	-- 效果原文：●从卡组把1只幻龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23068051,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c23068051.target)
	e1:SetOperation(c23068051.activate)
	c:RegisterEffect(e1)
	-- 效果原文：●从手卡以及自己场上的表侧表示怪兽之中把幻龙族怪兽任意数量送去墓地才能发动。自己从卡组抽出送去墓地的怪兽的数量＋1张。
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
-- 过滤函数：检索满足条件的幻龙族怪兽（可加入手牌）
function c23068051.filter(c)
	return c:IsRace(RACE_WYRM) and c:IsAbleToHand()
end
-- 效果处理：判断是否可以检索幻龙族怪兽（卡组）
function c23068051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查卡组是否存在满足条件的幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23068051.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置连锁操作信息为检索幻龙族怪兽（卡组）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：执行检索幻龙族怪兽效果
function c23068051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：选择满足条件的幻龙族怪兽（卡组）
	local g=Duel.SelectMatchingCard(tp,c23068051.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的幻龙族怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检索满足条件的幻龙族怪兽（手牌或场上表侧表示）
function c23068051.filter2(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsRace(RACE_WYRM) and c:IsAbleToGraveAsCost()
end
-- 效果处理：执行送去墓地并抽卡效果
function c23068051.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查手牌或场上是否存在满足条件的幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23068051.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 规则层面：获取玩家卡组剩余卡数
	local ft=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	-- 规则层面：获取满足条件的幻龙族怪兽组（手牌或场上）
	local g=Duel.GetMatchingGroup(c23068051.filter2,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	local ct=math.min(ft-1,g:GetCount()+1)
	local sg=g:Select(tp,1,ct,nil)
	e:SetLabel(sg:GetCount()+1)
	-- 规则层面：将选中的幻龙族怪兽送去墓地作为代价
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 效果处理：设置抽卡效果的目标
function c23068051.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 规则层面：设置连锁操作对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面：设置连锁操作对象参数为抽卡数量
	Duel.SetTargetParam(e:GetLabel())
	-- 规则层面：设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果处理：执行抽卡效果
function c23068051.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁操作对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
