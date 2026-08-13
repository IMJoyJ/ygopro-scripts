--守護神の宝札
-- 效果：
-- ①：丢弃5张手卡才能把这张卡发动。自己从卡组抽2张。
-- ②：只要这张卡在魔法与陷阱区域存在，自己抽卡阶段的通常抽卡变成2张。
function c17052477.initial_effect(c)
	-- ①：丢弃5张手卡才能把这张卡发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17052477.cost)
	e1:SetTarget(c17052477.target)
	e1:SetOperation(c17052477.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己抽卡阶段的通常抽卡变成2张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价函数：先检查手牌中是否存在足够的可丢弃卡，确认后让玩家丢弃5张手卡作为发动代价。
function c17052477.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认自己手牌中是否存在至少5张可丢弃的卡，且排除发动中的这张卡本身（因为这张卡是从手牌发动而非丢弃）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,5,e:GetHandler()) end
	-- 执行代价：让玩家从手牌选择并丢弃5张可丢弃的卡，丢弃原因标记为‘代价+丢弃’。
	Duel.DiscardHand(tp,Card.IsDiscardable,5,5,REASON_COST+REASON_DISCARD)
end
-- 效果①的目标设定函数：检查发动者能否抽2张卡，若能则设置抽卡对象玩家为发动者、抽卡数参数为2，并声明抽卡操作信息。
function c17052477.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认玩家tp可以因效果抽2张卡（是否存在‘不能抽卡’等限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设为tp，即指定抽卡效果影响的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为2，即指定抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 设置操作信息：声明本连锁的处理包含‘抽卡’类别，预计让玩家tp抽2张卡，供其他卡检测此次抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果①处理阶段的执行函数：从连锁信息中取出之前记录的目标玩家和抽卡数量，让该玩家抽相应数量的卡。
function c17052477.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中分别取出目标玩家p和目标参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以‘效果处理’为原因抽d张卡（实际抽卡操作）。
	Duel.Draw(p,d,REASON_EFFECT)
end
