--巨大戦艦 ビッグ・コア
-- 效果：
-- 这张卡召唤时放置3个指示物。这张卡不会被战斗破坏。进行战斗的场合，伤害步骤终了时取除这张卡的1个指示物。没有指示物的状态下进行战斗的场合，伤害步骤终了时这张卡破坏。
function c14148099.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这张卡召唤时放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14148099,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c14148099.addct)
	e1:SetOperation(c14148099.addc)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 注册一个在伤害步骤结束时触发的效果，用于处理战斗后指示物移除或卡片破坏的判定。
	aux.EnableBESRemove(c)
end
-- 设置召唤成功时触发的效果目标函数。
function c14148099.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置该效果在发动时会处理3个指示物的放置操作。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 设置召唤成功时触发的效果运算函数。
function c14148099.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
