--可変機獣 ガンナードラゴン
-- 效果：
-- ①：这张卡可以不用解放作通常召唤。
-- ②：这张卡的①的方法通常召唤的这张卡的原本的攻击力·守备力变成一半。
function c51632798.initial_effect(c)
	-- ①：这张卡可以不用解放作通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51632798,0))  --"不使用祭品通常召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c51632798.ntcon)
	e1:SetOperation(c51632798.ntop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
end
-- 判断是否满足不需解放的通常召唤条件
function c51632798.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足不需解放、等级5以上且场上存在空位的条件
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 设置该卡原本攻击力和守备力变为一半的效果
function c51632798.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置自身原本攻击力变成1400
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1400)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
