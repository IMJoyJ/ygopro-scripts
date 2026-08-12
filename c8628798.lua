--D.D.ダイナマイト
-- 效果：
-- 给与对方基本分对方除外的卡数×300的伤害。
function c8628798.initial_effect(c)
	-- 给与对方基本分对方除外的卡数×300的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c1)
	e1:SetTarget(c8628798.target)
	e1:SetOperation(c8628798.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认与准备函数，检查对方除外区是否有卡并设定伤害参数
function c8628798.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方除外区是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_REMOVED,1,nil) end
	-- 将当前连锁的对象玩家设定为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算发动时对方除外区的卡片数量乘以300的伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_REMOVED,0)*300
	-- 将计算出的伤害值设定为当前连锁的对象参数
	Duel.SetTargetParam(dam)
	-- 设置操作信息，声明此效果将对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理的执行函数，获取目标玩家并计算最终伤害进行给与
function c8628798.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家（即对方）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理时，重新计算对方除外区的卡片数量乘以300的伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_REMOVED,0)*300
	-- 因效果给与目标玩家计算出的伤害值
	Duel.Damage(p,dam,REASON_EFFECT)
end
