--極超辰醒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把2只不能通常召唤的怪兽里侧表示除外才能发动。自己从卡组抽2张。
function c90384300.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把2只不能通常召唤的怪兽里侧表示除外才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90384300+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c90384300.cost)
	e1:SetTarget(c90384300.target)
	e1:SetOperation(c90384300.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡或自己场上表侧表示的、不能通常召唤且可以里侧表示除外的怪兽
function c90384300.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER)
		and not c:IsSummonableCard() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
-- 发动代价：从手卡或自己场上将2只不能通常召唤的怪兽里侧表示除外
function c90384300.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡及自己场上是否存在至少2只满足代价条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90384300.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择2只满足代价条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c90384300.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,2,nil)
	local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
	-- 若选中的怪兽中包含手卡，则向对方展示这些手卡
	if #hg>0 then Duel.ConfirmCards(1-tp,hg) end
	-- 将选中的怪兽里侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 效果发动时的合法性检查与目标设定
function c90384300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能够抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果处理的目标玩家为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为抽卡，数量为2张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡
function c90384300.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
