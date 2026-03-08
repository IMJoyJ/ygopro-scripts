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
-- 过滤函数，用于筛选场上满足条件的通常怪兽（排除衍生物）
function c43714890.cfilter(c)
	local tp=c:GetType()
	return bit.band(tp,TYPE_NORMAL)~=0 and bit.band(tp,TYPE_TOKEN)==0
end
-- 效果的解放费用处理，检查并选择1只符合条件的怪兽进行解放
function c43714890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的通常怪兽（衍生物除外）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c43714890.cfilter,1,nil) end
	-- 从玩家场上选择1张满足条件的可解放的通常怪兽（衍生物除外）
	local sg=Duel.SelectReleaseGroup(tp,c43714890.cfilter,1,1,nil)
	-- 将选中的怪兽以代价原因进行解放
	Duel.Release(sg,REASON_COST)
end
-- 设置效果的目标玩家和参数，准备造成伤害
function c43714890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁效果的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁效果的目标参数设置为800点伤害
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息，指定为伤害效果并设定目标玩家和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果的发动处理，根据连锁信息对目标玩家造成指定伤害
function c43714890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
