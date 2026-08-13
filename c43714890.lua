--人投げトロール
-- 效果：
-- 每祭掉自己场上1只通常怪兽（衍生物除外），给与对方基本分800分的伤害。
function c43714890.initial_effect(c)
	-- 每祭掉自己场上1只通常怪兽（衍生物除外），给与对方基本分800分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43714890,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c43714890.cost)
	e1:SetTarget(c43714890.target)
	e1:SetOperation(c43714890.operation)
	c:RegisterEffect(e1)
end
-- 定义祭品过滤条件：怪兽的类型必须是通常怪兽，且不是衍生物。
function c43714890.cfilter(c)
	local tp=c:GetType()
	return bit.band(tp,TYPE_NORMAL)~=0 and bit.band(tp,TYPE_TOKEN)==0
end
-- 代价函数：发动前检查是否存在符合条件的通常怪兽，存在则选择1只并解放作为发动代价。
function c43714890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在费用检查阶段，确认自己场上是否存在至少1只满足条件的可解放怪兽，以决定效果能否发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c43714890.cfilter,1,nil) end
	-- 从自己场上选择1只满足条件的通常怪兽（衍生物除外）作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c43714890.cfilter,1,1,nil)
	-- 将选择的怪兽解放，解放原因标记为代价（REASON_COST），完成发动代价的支付。
	Duel.Release(sg,REASON_COST)
end
-- 目标函数：效果发动时指定对象为对方玩家，设定伤害值为800，并登记操作信息。
function c43714890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果对象参数设为800，表示将要造成的伤害数值。
	Duel.SetTargetParam(800)
	-- 设置连锁操作信息为伤害效果，对象为对方玩家，预计伤害为800，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理函数：实际执行给对方造成伤害的操作。
function c43714890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前指定的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）向对象玩家造成800点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
