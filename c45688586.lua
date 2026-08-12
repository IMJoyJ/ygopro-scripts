--カラクリ蜘蛛
-- 效果：
-- 这张卡攻击的怪兽是暗属性的场合，那只怪兽破坏，伤害的计算适用。
function c45688586.initial_effect(c)
	-- 这张卡攻击的怪兽是暗属性的场合，那只怪兽破坏，伤害的计算适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45688586,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c45688586.target)
	e1:SetOperation(c45688586.operation)
	c:RegisterEffect(e1)
end
-- 检查是否为攻击状态且战斗对象为暗属性怪兽
function c45688586.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断攻击怪兽是否为暗属性
	if chk==0 then return c==Duel.GetAttacker() and bc and bc:IsAttribute(ATTRIBUTE_DARK) end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 执行破坏效果
function c45688586.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
