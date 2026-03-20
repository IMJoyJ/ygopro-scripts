--ブラック・サンダー
-- 效果：
-- 自己场上存在的名字带有「黑羽」的怪兽被战斗破坏送去墓地时才能发动。对方场上存在的卡每有1张，给与对方基本分400分伤害。
function c52833089.initial_effect(c)
	-- 自己场上存在的名字带有「黑羽」的怪兽被战斗破坏送去墓地时才能发动。对方场上存在的卡每有1张，给与对方基本分400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c52833089.condition)
	e1:SetTarget(c52833089.target)
	e1:SetOperation(c52833089.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的卡片，包括名字带「黑羽」、在墓地、之前属于玩家、且是因战斗破坏被送去墓地的怪兽。
function c52833089.cfilter(c,tp)
	return c:IsSetCard(0x33) and c:IsLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(tp) and bit.band(c:GetReason(),REASON_BATTLE)~=0
end
-- 判断是否有满足cfilter条件的怪兽被战斗破坏并送入墓地。
function c52833089.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52833089.cfilter,1,nil,tp)
end
-- 设置连锁处理时的目标玩家为对方，并设定将要造成400点伤害的效果信息。
function c52833089.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在卡牌，若无则不发动效果。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	-- 将当前连锁的目标玩家设为对方（1-tp表示对方玩家）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息为造成伤害，目标玩家为对方，伤害值为400。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 处理效果发动时的伤害计算与执行。
function c52833089.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即受到伤害的玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 统计目标玩家场上的卡牌数量并乘以400作为总伤害值。
	local d=Duel.GetFieldGroupCount(p,LOCATION_ONFIELD,0)*400
	-- 对目标玩家造成相应伤害，伤害原因为效果（REASON_EFFECT）
	Duel.Damage(p,d,REASON_EFFECT)
end
