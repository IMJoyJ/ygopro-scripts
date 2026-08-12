--The splendid VENUS
-- 效果：
-- ①：只要这张卡在怪兽区域存在，天使族以外的场上的怪兽的攻击力·守备力下降500，自己场上的魔法·陷阱卡的效果的发动以及那些发动的效果不会被无效化。
function c5645210.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，天使族以外的场上的怪兽的攻击力·守备力下降500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c5645210.target)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，天使族以外的场上的怪兽的攻击力·守备力下降500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c5645210.target)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- 自己场上的魔法·陷阱卡的效果的发动以及那些发动的效果不会被无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c5645210.effectfilter)
	c:RegisterEffect(e4)
	-- 自己场上的魔法·陷阱卡的效果的发动以及那些发动的效果不会被无效化
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c5645210.effectfilter)
	c:RegisterEffect(e5)
end
-- 判断目标怪兽是否为表侧表示且非天使族
function c5645210.target(e,c)
	return c:IsFaceup() and not c:IsRace(RACE_FAIRY)
end
-- 判断当前连锁是否为自己场上发动的魔法或陷阱卡的效果
function c5645210.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取指定连锁的效果、发动玩家以及发动位置
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and bit.band(loc,LOCATION_ONFIELD)~=0
end
