--キャッスル・ゲート
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：1回合1次，这张卡在场上攻击表示存在的场合，把自己场上1只5星以下的怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
function c36931229.initial_effect(c)
	-- 效果原文内容：①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，这张卡在场上攻击表示存在的场合，把自己场上1只5星以下的怪兽解放才能发动。给与对方解放的怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36931229,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c36931229.condition)
	e2:SetCost(c36931229.cost)
	e2:SetTarget(c36931229.target)
	e2:SetOperation(c36931229.operation)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断效果是否可以发动，条件为该卡必须处于攻击表示。
function c36931229.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 规则层面作用：过滤函数，用于筛选场上5星以下且攻击力大于0的怪兽。
function c36931229.filter(c)
	return c:IsLevelBelow(5) and c:GetTextAttack()>0
end
-- 规则层面作用：处理效果的解放费用，检查并选择满足条件的怪兽进行解放。
function c36931229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检测是否满足解放条件，即场上是否存在符合条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c36931229.filter,1,nil) end
	-- 规则层面作用：从场上选择一张符合条件的怪兽作为解放对象。
	local sg=Duel.SelectReleaseGroup(tp,c36931229.filter,1,1,nil)
	e:SetLabel(sg:GetFirst():GetTextAttack())
	-- 规则层面作用：将选中的怪兽以代價原因进行解放。
	Duel.Release(sg,REASON_COST)
end
-- 规则层面作用：设置连锁处理时的目标玩家和伤害值。
function c36931229.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置连锁处理时的目标玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面作用：设置连锁处理时的目标参数为解放怪兽的攻击力。
	Duel.SetTargetParam(e:GetLabel())
	-- 规则层面作用：设置连锁操作信息，表明将对对方造成指定数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 规则层面作用：执行连锁效果，对指定玩家造成相应数值的伤害。
function c36931229.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标玩家和目标参数（即伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：以效果原因对目标玩家造成指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
