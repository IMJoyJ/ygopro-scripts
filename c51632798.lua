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
-- 无解放通常召唤的召唤规则效果的发动条件：当c为空时视为可适用；否则要求解放数量为0、此卡等级≥5且我方主要怪兽区有空位。
function c51632798.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定条件：无需解放（minc==0）、此卡等级不低于5、且控制者场上的主要怪兽区存在可用空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放通常召唤成功后的处理：为此卡注册持续效果，使其原本攻击力变为1400、原本守备力变为1000；此效果仅在怪兽区适用，且会因离场等事件被重置。
function c51632798.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法通常召唤的这张卡的原本的攻击力·守备力变成一半。
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
