--エレキンメダイ
-- 效果：
-- 这张卡直接攻击给与对方基本分战斗伤害时，对方手卡随机丢弃1张。
function c5554990.initial_effect(c)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，对方手卡随机丢弃1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5554990,0))
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c5554990.condition)
	e1:SetTarget(c5554990.target)
	e1:SetOperation(c5554990.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否满足：直接攻击给与对方基本分战斗伤害
function c5554990.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认受到伤害的玩家是对方，且攻击对象为空（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果发动的目标确认与操作信息设置
function c5554990.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理：对方手卡随机丢弃1张
function c5554990.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到伤害的玩家（对方）的所有手牌
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选中的卡片以效果丢弃的形式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
