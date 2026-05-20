--ゴロゴル
-- 效果：
-- 和这张卡进行战斗的对方怪兽在伤害步骤结束时变成里侧守备表示。
function c59797187.initial_effect(c)
	-- 和这张卡进行战斗的对方怪兽在伤害步骤结束时变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59797187,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置效果发动条件为伤害步骤结束时，且自身仍与战斗关联或已被战斗破坏
	e1:SetCondition(aux.dsercon)
	e1:SetTarget(c59797187.target)
	e1:SetOperation(c59797187.operation)
	c:RegisterEffect(e1)
end
-- 获取与自身进行战斗的怪兽，并在其仍与战斗关联时确认其为效果处理对象，设置改变表示形式的操作信息
function c59797187.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=e:GetHandler():GetBattleTarget()
	if chk==0 then return tg and tg:IsRelateToBattle() end
	-- 设置改变表示形式的操作信息，涉及1张与战斗关联的怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tg,1,0,0)
end
-- 在效果处理时，若与自身进行战斗的怪兽仍与战斗关联且呈表侧表示，则将其改变为里侧守备表示
function c59797187.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 将目标怪兽的表示形式改变为里侧守备表示
		Duel.ChangePosition(bc,POS_FACEDOWN_DEFENSE)
	end
end
