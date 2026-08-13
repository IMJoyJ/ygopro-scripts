--銀河の施し
-- 效果：
-- 自己场上有名字带有「银河」的超量怪兽存在的场合，丢弃1张手卡才能发动。从卡组抽2张卡。这张卡发动过的回合，对方受到的全部伤害变成一半。「银河的施舍」在1回合只能发动1张。
function c20349913.initial_effect(c)
	-- 自己场上有名字带有「银河」的超量怪兽存在的场合，丢弃1张手卡才能发动。从卡组抽2张卡。这张卡发动过的回合，对方受到的全部伤害变成一半。「银河的施舍」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20349913+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20349913.condition)
	e1:SetCost(c20349913.cost)
	e1:SetTarget(c20349913.target)
	e1:SetOperation(c20349913.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：检测卡是否为表侧表示、是否属于「银河」系列（0x7b）且为超量怪兽，用于后续判断场上是否存在符合发动条件的超量怪兽。
function c20349913.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ)
end
-- 发动条件判定函数：检查自己场上是否存在至少1只满足cfilter筛选条件的表侧表示「银河」超量怪兽。
function c20349913.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 通过Duel.IsExistingMatchingCard检查自己场上（LOCATION_MZONE）是否存在至少1张满足cfilter条件的卡，作为发动的条件判断。
	return Duel.IsExistingMatchingCard(c20349913.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价函数：确认可以丢弃1张手卡，并执行丢弃手卡的代价。
function c20349913.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查阶段，确认手牌中是否存在至少1张可以丢弃的卡（且不是发动效果的这张卡），以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价，从手牌中选择1张可以丢弃的卡以丢弃（原因设为COST和DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果的目标设定函数：设置抽卡效果的对象为自己、抽卡数为2，并登记效果信息，供后续处理时使用。
function c20349913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标合法性检查阶段，确认自己是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设为发动者tp，表示之后由此玩家抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果参数为2，表示抽卡张数为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：该效果属于抽卡（CATEGORY_DRAW），预计抽卡玩家为tp、抽卡数为2（处理时再实际抽卡，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：根据之前设定的对象玩家和参数执行抽卡，并在本回合内为对方受到的全部伤害设置减半的永续效果。
function c20349913.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中设定的目标玩家p和参数d，用于决定抽卡者和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽d张卡（此处即让发动者抽2张卡），原因为效果。
	Duel.Draw(p,d,REASON_EFFECT)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡发动过的回合，对方受到的全部伤害变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(c20349913.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将伤害减半的永续效果注册到场上，归属于发动者tp，使其在当前回合内持续适用。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害数值计算函数：将受到的伤害值向下取整为一半，即对方受到的伤害减半。
function c20349913.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
