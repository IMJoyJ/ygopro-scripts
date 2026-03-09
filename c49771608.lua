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
-- 检查进行战斗的怪兽和被战斗破坏的怪兽是否有效，且被破坏怪兽在墓地且为怪兽类型
function c49771608.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 计算回复的基本分值并设置连锁操作信息
function c49771608.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rec=e:GetHandler():GetBattleTarget():GetLevel()*300
	-- 设置连锁操作的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作的目标参数为计算出的回复基本分值
	Duel.SetTargetParam(rec)
	-- 设置连锁操作信息为回复效果，目标玩家和参数已设定
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 执行回复基本分的操作
function c49771608.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁操作中设定的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定的基本分值，原因来自效果
	Duel.Recover(p,d,REASON_EFFECT)
end
