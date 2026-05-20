--全弾発射
-- 效果：
-- 这张卡发动后，把手卡全部送去墓地。给与对方基本分送去墓地的卡数量×200数值的伤害。
function c70865988.initial_effect(c)
	-- 这张卡发动后，把手卡全部送去墓地。给与对方基本分送去墓地的卡数量×200数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c70865988.target)
	e1:SetOperation(c70865988.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与预设处理
function c70865988.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：自己手卡数量必须大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算预估伤害值（以对方手卡数量×200计算）
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*200
	-- 设置伤害的预估参数
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息，表明此效果会造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 定义效果的具体执行处理
function c70865988.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将自己的手卡全部送去墓地，并确认是否有卡片成功送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		-- 获取刚刚实际被送去墓地的卡片组
		local og=Duel.GetOperatedGroup()
		local dam=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)*200
		-- 获取效果的目标玩家（即伤害承受方）
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 给与目标玩家计算出的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
