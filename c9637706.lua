--デス・ウォンバット
-- 效果：
-- 只要这张卡在场上表侧表示存在，控制者受到的卡的效果的伤害为0。
function c9637706.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，控制者受到的卡的效果的伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c9637706.damval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2)
end
-- 判断伤害原因，如果是效果伤害则将伤害值变为0，否则保持原伤害值
function c9637706.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
