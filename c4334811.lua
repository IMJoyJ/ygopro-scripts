--スクラップ・リサイクラー
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只机械族怪兽送去墓地。
-- ②：1回合1次，让自己墓地2只机械族·地属性·4星怪兽回到卡组才能发动。自己从卡组抽1张。
function c4334811.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只机械族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4334811,0))  --"选择1只机械族怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c4334811.target)
	e1:SetOperation(c4334811.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，让自己墓地2只机械族·地属性·4星怪兽回到卡组才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4334811,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c4334811.drcost)
	e3:SetTarget(c4334811.drtg)
	e3:SetOperation(c4334811.drop)
	c:RegisterEffect(e3)
end
-- 筛选函数：判断卡片是否为怪兽、机械族且可以被送去墓地，用于从卡组选择符合条件的机械族怪兽。
function c4334811.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 效果①的发动条件和操作信息设置函数：检查卡组中是否存在可送去墓地的机械族怪兽，并设置“送去墓地”的操作信息。
function c4334811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在至少1只满足tgfilter条件的机械族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4334811.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁为将被选择的卡送去墓地的效果，预计从卡组送去墓地1张，操作玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理时的执行函数：实际从卡组选择1只机械族怪兽，并将其送去墓地。
function c4334811.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家从卡组选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选择1张满足tgfilter条件的机械族怪兽。
	local g=Duel.SelectMatchingCard(tp,c4334811.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 筛选函数：判断墓地中的卡是否为机械族、地属性、4星怪兽，且可以作为返回卡组的代价。
function c4334811.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsAbleToDeckAsCost()
end
-- 效果②的发动代价函数：从自己墓地选择2只机械族·地属性·4星怪兽返回卡组并洗牌，作为发动代价。
function c4334811.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：墓地中是否存在至少2张满足cfilter条件的机械族·地属性·4星怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4334811.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 弹出选择提示，提示玩家从墓地选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择2张满足cfilter条件的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c4334811.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 显示所选卡片被选为代价的动画，并记录这些卡。
	Duel.HintSelection(g)
	-- 将选择的2张卡返回持有者卡组，洗牌，作为效果发动代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果②的发动目标函数：确认玩家可以抽卡，并设置抽卡玩家和抽卡数量。
function c4334811.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：玩家tp是否可以抽1张卡，若不能抽卡则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为tp，表示由该玩家进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本次连锁为抽卡效果，目标玩家为tp，预期抽卡数量为1（count为0表示不指定对象卡）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②处理时的执行函数：根据发动时记录的目标玩家和抽卡数量执行抽卡。
function c4334811.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽d张卡（因效果抽卡），完成抽卡效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
