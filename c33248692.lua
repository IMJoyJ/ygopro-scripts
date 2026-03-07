--オプションハンター
-- 效果：
-- 自己场上的怪兽被战斗破坏送去墓地时发动。自己回复破坏怪兽的原本攻击力的数值的基本分。
function c33248692.initial_effect(c)
	-- 效果原文内容：自己场上的怪兽被战斗破坏送去墓地时发动。自己回复破坏怪兽的原本攻击力的数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c33248692.condition)
	e1:SetTarget(c33248692.target)
	e1:SetOperation(c33248692.operation)
	c:RegisterEffect(e1)
end
-- 规则层面操作：筛选出上一个控制者为自己、位置在墓地、被战斗破坏的怪兽
function c33248692.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 规则层面操作：判断是否有满足条件的怪兽被战斗破坏
function c33248692.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33248692.filter,1,nil,tp)
end
-- 规则层面操作：计算满足条件的怪兽的原本攻击力并设置回复基本分的参数
function c33248692.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rec=eg:Filter(c33248692.filter,nil,tp):GetFirst():GetBaseAttack()
	if rec<0 then rec=0 end
	-- 规则层面操作：设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置效果的目标参数为回复的基本分数值
	Duel.SetTargetParam(rec)
	-- 规则层面操作：设置连锁的操作信息为回复基本分效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 规则层面操作：从连锁信息中获取目标玩家和参数值并执行回复基本分效果
function c33248692.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：从当前连锁中获取目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：以效果原因使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
