--紋章獣バシリスク
-- 效果：
-- 这张卡和对方怪兽进行战斗的伤害计算后，那只对方怪兽破坏。
function c56921677.initial_effect(c)
	-- 这张卡和对方怪兽进行战斗的伤害计算后，那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56921677,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c56921677.condition)
	e1:SetTarget(c56921677.target)
	e1:SetOperation(c56921677.operation)
	c:RegisterEffect(e1)
end
-- 确认与这张卡进行战斗的怪兽是否存在
function c56921677.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 必发效果的target函数，将进行战斗的对方怪兽设为效果处理的对象并设置破坏的操作信息
function c56921677.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	-- 将进行战斗的对方怪兽设为效果处理的对象
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示该连锁的处理为破坏1张目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理，获取目标怪兽并将其因效果破坏
function c56921677.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
