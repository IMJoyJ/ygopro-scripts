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
	-- 启用“B.E.S.”（巨大战舰）系列通用效果：进行战斗的伤害步骤结束时，有指示物则取除1个指示物，无指示物则这张卡破坏。
	aux.EnableBESRemove(c)
end
-- 诱发效果的发动条件判定：chk==0 时返回 true 表示满足发动条件，并设置本次连锁的操作信息，预告将放置3个指示物。
function c14148099.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：分类为指示物效果（CATEGORY_COUNTER），对象不确定，数量为3，玩家为0，指示物类型为0x1f，供效果处理时记录及后续检测。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 效果处理时，若这张卡仍与效果有关联，则为这张卡添加3个0x1f类型的指示物。
function c14148099.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
