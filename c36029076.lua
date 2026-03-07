--地獄大百足
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1300。
function c36029076.initial_effect(c)
	-- 效果原文内容：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36029076,0))  --"不解放怪兽进行召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c36029076.ntcon)
	e1:SetOperation(c36029076.ntop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否满足不需解放的召唤条件
function c36029076.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：判断召唤者场上是否有足够的怪兽区域
	return minc==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 规则层面作用：判断召唤者场上是否不存在怪兽
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 规则层面作用：设置召唤后这张卡的原本攻击力变为1300
function c36029076.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 效果原文内容：这个方法召唤的这张卡的原本攻击力变成1300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1300)
	c:RegisterEffect(e1)
end
