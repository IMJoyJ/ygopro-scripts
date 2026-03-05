--キューブン
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。只要这只怪兽在场上表侧表示存在，双方不能把和出现的数目相同等级的怪兽召唤·特殊召唤。
function c17530001.initial_effect(c)
	-- 效果原文内容：①：1回合1次，自己主要阶段才能发动。掷1次骰子。只要这只怪兽在场上表侧表示存在，双方不能把和出现的数目相同等级的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17530001,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c17530001.target)
	e1:SetOperation(c17530001.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置连锁处理时的骰子效果信息
function c17530001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置骰子效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果作用：执行骰子投掷并设置等级限制效果
function c17530001.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 效果作用：投掷一次骰子并获取结果
	local dc=Duel.TossDice(tp,1)
	-- 效果原文内容：只要这只怪兽在场上表侧表示存在，双方不能把和出现的数目相同等级的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c17530001.tglimit)
	e1:SetLabel(dc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e2)
end
-- 效果作用：判断目标怪兽是否为指定等级
function c17530001.tglimit(e,c)
	return c:IsLevel(e:GetLabel())
end
