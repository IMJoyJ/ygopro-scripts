--地獄大百足
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1300。
function c36029076.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36029076,0))  --"不解放怪兽进行召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c36029076.ntcon)
	e1:SetOperation(c36029076.ntop)
	c:RegisterEffect(e1)
end
-- 无解放召唤的规则判定：c==nil时用于规则查询返回可召唤；否则要求本次召唤无需解放、己方主怪兽区有空位、对方场上有怪兽且己方场上无怪兽。
function c36029076.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认本次召唤不需要解放（minc==0）且己方主要怪兽区域有空余格子。
	return minc==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认对方场上有怪兽存在（对方场上怪兽区怪兽数量大于0）。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 确认己方场上没有怪兽存在（己方怪兽区怪兽数量为0）。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 无解放召唤成功后的处理：给这张卡注册一个仅在场上存在的永续效果，将其原本攻击力设为1300（离场或重置时失效）。
function c36029076.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的这张卡的原本攻击力变成1300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1300)
	c:RegisterEffect(e1)
end
