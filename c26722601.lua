--インヴェルズの門番
-- 效果：
-- 只要这张卡在场上表侧表示存在，名字带有「侵入魔鬼」的怪兽表侧表示上级召唤成功的回合，自己在通常召唤外加上只有1次可以把怪兽通常召唤。
function c26722601.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，名字带有「侵入魔鬼」的怪兽表侧表示上级召唤成功的回合，自己在通常召唤外加上只有1次可以把怪兽通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c26722601.sumop)
	c:RegisterEffect(e1)
end
-- 当满足条件时，为自身注册一个效果，使自己可以在通常召唤外加上只有1次可以把怪兽通常召唤
function c26722601.sumop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local c=e:GetHandler()
	if ec~=e:GetHandler() and ec:IsSetCard(0x100a) and ec:IsSummonType(SUMMON_TYPE_ADVANCE) then
		-- 使用「侵入魔鬼的门番」的效果召唤
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(26722601,0))  --"使用「侵入魔鬼的门番」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SET_COUNT)
		c:RegisterEffect(e2)
	end
end
