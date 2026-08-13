--狭き通路
-- 效果：
-- 双方场上的怪兽都在2只以下时才能发动。双方都至多只能往自己场上召唤2只怪兽。
function c40172183.initial_effect(c)
	-- 卡片效果原文：“双方场上的怪兽都在2只以下时才能发动。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c40172183.condition)
	c:RegisterEffect(e1)
	-- 卡片效果原文：“双方都至多只能往自己场上召唤2只怪兽。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c40172183.sumlimit)
	c:RegisterEffect(e2)
end
-- 定义该魔法卡的发动条件函数：仅在己方场上怪兽数不超过2只且对方场上怪兽数不超过2只时，此卡才能发动。
function c40172183.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区域的怪兽数量是否不超过2只。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=2
		-- 检查对方主要怪兽区域的怪兽数量是否不超过2只。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=2
end
-- 定义召唤限制的判定函数：当要进行通常召唤的玩家sp自己场上已有2只或更多怪兽时，禁止其继续召唤。
function c40172183.sumlimit(e,c,sp,st)
	-- 判断进行召唤的玩家sp的主要怪兽区域的怪兽数量是否达到2只或以上，若达到则不允许其继续通常召唤。
	return Duel.GetFieldGroupCount(sp,LOCATION_MZONE,0)>=2
end
