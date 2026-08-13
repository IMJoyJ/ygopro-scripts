--調和の宝札
-- 效果：
-- ①：从手卡丢弃1只攻击力1000以下的龙族调整才能发动。自己从卡组抽2张。
function c39701395.initial_effect(c)
	-- ①：从手卡丢弃1只攻击力1000以下的龙族调整才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c39701395.cost)
	e1:SetTarget(c39701395.target)
	e1:SetOperation(c39701395.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的卡：攻击力1000以下、龙族、调整怪兽，且可以作为代价从手卡丢弃。
function c39701395.filter(c)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_DRAGON) and c:IsAttackBelow(1000) and c:IsDiscardable()
end
-- 发动代价处理：先检查手卡是否存在符合条件的龙族调整，若有则选择1只丢弃作为发动代价。
function c39701395.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段（chk==0）检查手卡是否存在至少1只满足条件的龙族调整怪兽，以此判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c39701395.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从手卡选择1只符合条件的龙族调整怪兽，以“代价+丢弃”为原因将其丢弃。
	Duel.DiscardHand(tp,c39701395.filter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的目标设定：确认玩家可以抽卡，将抽卡对象玩家设为发动者，并登记抽2张卡的操作信息。
function c39701395.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：确认玩家tp可以抽2张卡（没有受到不能抽卡的效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设置为发动者tp，表示后续抽卡作用于该玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设置为2，表示抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本连锁将执行抽卡效果，目标为玩家tp，预计抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理阶段：从连锁信息中取出对象玩家和抽卡数量，并让该玩家抽对应数量的卡。
function c39701395.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家p和抽卡参数d，用于执行抽卡效果。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡（d为2），完成“自己从卡组抽2张”的效果处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
