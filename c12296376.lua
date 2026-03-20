--エレキツツキ
-- 效果：
-- 这张卡在同1次的战斗阶段中可以作2次攻击。和这张卡进行过战斗的怪兽不能把表示形式变更。
function c12296376.initial_effect(c)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 和这张卡进行过战斗的怪兽不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c12296376.operation)
	c:RegisterEffect(e2)
end
-- 当此卡参与战斗时，检索与该卡战斗的怪兽并为其注册不能改变表示形式的效果。
function c12296376.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc then return end
	-- 和这张卡进行过战斗的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	bc:RegisterEffect(e1)
end
