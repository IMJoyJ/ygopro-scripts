--狭き通路
-- 效果：
-- 双方场上的怪兽都在2只以下时才能发动。双方都至多只能往自己场上召唤2只怪兽。
function c40172183.initial_effect(c)
	-- 双方场上的怪兽都在2只以下时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c40172183.condition)
	c:RegisterEffect(e1)
	-- 双方都至多只能往自己场上召唤2只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c40172183.sumlimit)
	c:RegisterEffect(e2)
end
-- 判断双方场上怪兽数量是否都不超过2只
function c40172183.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断我方场上怪兽数量是否不超过2只
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=2
		-- 判断对方场上怪兽数量是否不超过2只
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=2
end
-- 限制召唤数量的效果函数
function c40172183.sumlimit(e,c,sp,st)
	-- 当己方场上怪兽数量达到2只时禁止召唤
	return Duel.GetFieldGroupCount(sp,LOCATION_MZONE,0)>=2
end
