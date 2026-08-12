--アトラの蟲惑魔
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ②：只要这张卡在怪兽区域存在，自己可以把「洞」通常陷阱卡以及「落穴」通常陷阱卡从手卡发动。
-- ③：只要这张卡在怪兽区域存在，自己的通常陷阱卡的发动以及那些发动的效果不会被无效化。
function c55428242.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c55428242.efilter)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己可以把「洞」通常陷阱卡以及「落穴」通常陷阱卡从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55428242,0))  --"适用「阿特拉之虫惑魔」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(c55428242.etarget)
	e2:SetValue(55428242)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己的通常陷阱卡的发动...不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c55428242.chainfilter)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，...以及那些发动的效果不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c55428242.chainfilter)
	c:RegisterEffect(e4)
end
-- 判断引发效果的卡片是否为「洞」或「落穴」通常陷阱卡，用于免疫效果的过滤
function c55428242.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 判断手牌中的卡片是否为「洞」或「落穴」通常陷阱卡，用于手牌发动效果的过滤
function c55428242.etarget(e,c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 判断连锁中的效果是否为自己发动的通常陷阱卡的效果，用于防止无效化效果的过滤
function c55428242.chainfilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取指定连锁序号对应的连锁效果以及发动该连锁的玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:GetActiveType()==TYPE_TRAP
end
