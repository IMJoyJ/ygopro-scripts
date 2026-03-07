--デルタ・アタッカー
-- 效果：
-- 这张卡仅当自己场上存在3只同名的通常怪兽（衍生物除外）时才能发动。这张卡发动的回合，这3只同名的通常怪兽可以对对方进行直接攻击。
function c39719977.initial_effect(c)
	-- 效果原文：这张卡仅当自己场上存在3只同名的通常怪兽（衍生物除外）时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39719977.target)
	e1:SetOperation(c39719977.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽：表侧表示的通常怪兽（非衍生物），并且场上存在另外2只同名的通常怪兽（非衍生物）
function c39719977.filter(c,tp)
	local tpe=c:GetType()
	return c:IsFaceup() and bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
		-- 检查场上是否存在另外2只同名的通常怪兽（非衍生物）
		and Duel.IsExistingMatchingCard(c39719977.filter2,tp,LOCATION_MZONE,0,2,c,c:GetCode())
end
-- 用于匹配同名通常怪兽（非衍生物）的过滤函数
function c39719977.filter2(c,code)
	local tpe=c:GetType()
	return c:IsFaceup() and bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0 and c:IsCode(code)
end
-- 效果原文：这张卡仅当自己场上存在3只同名的通常怪兽（衍生物除外）时才能发动。
function c39719977.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查场上是否存在至少3只同名的通常怪兽（非衍生物）
		and Duel.IsExistingMatchingCard(c39719977.filter,tp,LOCATION_MZONE,0,3,nil,tp) end
end
-- 效果原文：这张卡发动的回合，这3只同名的通常怪兽可以对对方进行直接攻击。
function c39719977.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的通常怪兽（非衍生物）
	local g=Duel.GetMatchingGroup(c39719977.filter,tp,LOCATION_MZONE,0,nil,tp)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽获得直接攻击效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
