--吸収天児
-- 效果：
-- 这张卡战斗破坏怪兽并将其送去墓地时，自己回复被破坏的怪兽等级×300基本分。
function c49771608.initial_effect(c)
	-- 这张卡战斗破坏怪兽并将其送去墓地时，自己回复被破坏的怪兽等级×300基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49771608,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c49771608.condition)
	e1:SetTarget(c49771608.target)
	e1:SetOperation(c49771608.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡仍与本次战斗关联，且其战斗破坏的怪兽在墓地里并是怪兽，满足时才发动回复效果。
function c49771608.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 发动时处理：通过战斗对象计算回复量（等级×300），将回复方设为本卡控制者，并将该回复效果的信息登记到连锁，供处理阶段使用。
function c49771608.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rec=e:GetHandler():GetBattleTarget():GetLevel()*300
	-- 将本次连锁的对象玩家设为当前控制者，即回复基本分的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设为计算出的回复数值。
	Duel.SetTargetParam(rec)
	-- 登记操作信息，声明这是一个回复效果，回复量为rec，对象玩家为tp，供时点/其他卡效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理阶段：从连锁信息中取出对象玩家和回复量，并执行基本分回复。
function c49771608.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中一次性取出此前设置的对象玩家（p）和回复数值（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
