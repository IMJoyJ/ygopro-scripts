--カンガルー・チャンプ
-- 效果：
-- 与这张卡进行战斗的怪兽，战斗伤害计算后变为守备表示。
function c95789089.initial_effect(c)
	-- 与这张卡进行战斗的怪兽，战斗伤害计算后变为守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95789089,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c95789089.cpcon)
	e1:SetTarget(c95789089.cptg)
	e1:SetOperation(c95789089.cpop)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件：获取与自身进行战斗的怪兽并保存，确认自身和该怪兽在伤害步骤结束时仍与战斗关联。
function c95789089.cpcon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 确认自身在伤害步骤结束时仍与战斗关联（或被战斗破坏），且存在与本次战斗关联的对方怪兽。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRelateToBattle()
end
-- 定义效果的目标：作为必发效果直接返回true，并设置改变表示形式的操作信息。
function c95789089.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将记录的战斗怪兽作为改变表示形式的对象。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetLabelObject(),1,0,0)
end
-- 定义效果的处理：若记录的怪兽仍与战斗关联且为攻击表示，则将其变为表侧守备表示。
function c95789089.cpop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g:IsRelateToBattle() and g:IsAttackPos() then
		-- 将目标怪兽改变为表侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
