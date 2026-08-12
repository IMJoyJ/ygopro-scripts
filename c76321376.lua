--マイン・ゴーレム
-- 效果：
-- 这张卡被战斗破坏送去墓地时，给与对方基本分500分伤害。
function c76321376.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76321376,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c76321376.damcon)
	e1:SetTarget(c76321376.damtg)
	e1:SetOperation(c76321376.damop)
	c:RegisterEffect(e1)
end
-- 确认自身是否因战斗破坏并送去墓地，作为效果发动的条件
function c76321376.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置效果发动的目标玩家、伤害数值，并注册造成伤害的操作信息
function c76321376.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500
	Duel.SetTargetParam(500)
	-- 向系统注册当前连锁的操作信息为给与对方玩家500分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 获取连锁信息中的目标玩家和伤害数值，并执行给与伤害的效果处理
function c76321376.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
