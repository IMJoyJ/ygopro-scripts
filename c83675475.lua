--トークン謝肉祭
-- 效果：
-- 衍生物特殊召唤时发动。场上存在的全部衍生物破坏，与对方基本分破坏的衍生物数量×300分的伤害。
function c83675475.initial_effect(c)
	-- 衍生物特殊召唤时发动。场上存在的全部衍生物破坏，与对方基本分破坏的衍生物数量×300分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c83675475.condition)
	e1:SetTarget(c83675475.target)
	e1:SetOperation(c83675475.activate)
	c:RegisterEffect(e1)
end
-- 检查特殊召唤的怪兽中是否存在衍生物，作为发动条件
function c83675475.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_TOKEN)
end
-- 效果发动的目标确认，收集场上的衍生物并设置破坏与伤害的操作信息
function c83675475.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 设置破坏的操作信息，指定要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害的操作信息，指定受伤害玩家为对方，伤害数值为衍生物数量×300
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*300)
end
-- 效果处理，破坏场上所有的衍生物，并根据实际破坏数量给予对方伤害
function c83675475.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 破坏所有衍生物，并获取实际被破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 给予对方实际破坏数量×300的伤害
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
