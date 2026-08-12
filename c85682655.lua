--ゼンマイジャグラー
-- 效果：
-- 这张卡和对方怪兽进行战斗的场合，可以把那只对方怪兽在伤害计算后破坏。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c85682655.initial_effect(c)
	-- 这张卡和对方怪兽进行战斗的场合，可以把那只对方怪兽在伤害计算后破坏。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85682655,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLED)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetTarget(c85682655.target)
	e1:SetOperation(c85682655.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认：获取与自身进行战斗的怪兽，确认其是否仍处于战斗关联状态，并设置破坏该怪兽的操作信息
function c85682655.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则将目标怪兽设定为被攻击的怪兽（即对方怪兽）
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsRelateToBattle() end
	-- 设置效果处理的操作信息，表示将要破坏1只目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理：获取与自身进行战斗的怪兽，若其仍处于战斗关联状态，则将其破坏
function c85682655.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则将目标怪兽设定为被攻击的怪兽（即对方怪兽）
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() then
		-- 用效果破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
