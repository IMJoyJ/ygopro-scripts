--九字切りの呪符
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只9星怪兽送去墓地才能发动。自己从卡组抽2张。
function c78543464.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把1只9星怪兽送去墓地才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78543464+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c78543464.cost)
	e1:SetTarget(c78543464.target)
	e1:SetOperation(c78543464.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡或自己场上表侧表示的、可以作为代价送去墓地的9星怪兽
function c78543464.costfilter(c)
	return c:IsLevel(9) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToGraveAsCost()
end
-- 发动代价处理：从手卡或自己场上将1只9星怪兽送去墓地
function c78543464.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡或自己场上是否存在可作为代价送去墓地的9星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78543464.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或自己场上选择1只满足条件的9星怪兽
	local g=Duel.SelectMatchingCard(tp,c78543464.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动目标确认与操作信息设置
function c78543464.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查玩家是否具有抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将效果处理的对象玩家设为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果处理的参数（抽卡张数）设为2
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为抽卡分类，数量为2张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡
function c78543464.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
