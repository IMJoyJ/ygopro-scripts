--災いの像
-- 效果：
-- 当这张卡因对方控制的卡的效果从手卡被送去墓地时，给与对方基本分2000分的伤害。
function c12160911.initial_effect(c)
	-- 当这张卡因对方控制的卡的效果从手卡被送去墓地时，给与对方基本分2000分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12160911,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c12160911.condition)
	e1:SetTarget(c12160911.target)
	e1:SetOperation(c12160911.operation)
	c:RegisterEffect(e1)
end
-- 判定诱发条件：这张卡是从手牌被送去墓地，且送墓原因是由对方控制的效果（rp为对方玩家），且原因为效果（REASON_EFFECT）。
function c12160911.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and rp==1-tp and bit.band(r,REASON_EFFECT)==REASON_EFFECT
end
-- 伤害效果的发动阶段：无需取对象；将对方玩家设为伤害对象，伤害数值设为2000，并登记操作信息供后续处理。
function c12160911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设置为对方玩家，作为伤害的承受方。
	Duel.SetTargetPlayer(1-tp)
	-- 把当前连锁的对象参数设置为2000，表示要造成的伤害数值。
	Duel.SetTargetParam(2000)
	-- 登记操作信息：本连锁将执行伤害效果，伤害对象为对方玩家，伤害值为2000（targets为nil表示不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 效果处理时的执行操作：从连锁信息中取出目标玩家和伤害数值，并给予对方玩家2000点效果伤害。
function c12160911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的目标玩家（p）和伤害数值（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）向玩家p造成d点伤害，即给予对方2000基本分伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
