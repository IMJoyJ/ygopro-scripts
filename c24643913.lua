--叛逆者エト
-- 效果：
-- 这张卡不能通常召唤。「叛逆者 埃图」1回合1次在持有以下效果的怪兽卡在对方的场上或墓地存在，把基本分支付一半的场合才能从手卡·墓地特殊召唤。
-- ●需在有效果发动时连锁并在手卡或怪兽区域发动的效果
-- ①：这张卡的特殊召唤不会被无效化。
-- ②：这张卡只要在怪兽区域存在，不能作为融合·同调·超量·连接召唤的素材，自己回合内不受对方场上发动的怪兽的效果影响。
local s,id,o=GetID()
-- 初始化效果函数，设置该卡的特殊召唤限制和各种永续效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「叛逆者 埃图」1回合1次在持有以下效果的怪兽卡在对方的场上或墓地存在，把基本分支付一半的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这张卡的特殊召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 这张卡只要在怪兽区域存在，不能作为融合·同调·超量·连接召唤的素材。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e7:SetValue(s.fuslimit)
	c:RegisterEffect(e7)
	-- 自己回合内不受对方场上发动的怪兽的效果影响。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_IMMUNE_EFFECT)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(s.efilter)
	c:RegisterEffect(e8)
end
-- 快速效果过滤器，用于判断是否为手卡或怪兽区域的诱发即时效果
function s.quick_filter(e)
	return (e:GetCode()==EVENT_CHAINING or e:GetCode()==EVENT_BECOME_TARGET) and e:IsHasType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F) and e:IsHasRange(LOCATION_HAND+LOCATION_MZONE)
end
-- 满足条件的怪兽卡过滤器，用于检测对方场上或墓地是否存在具有诱发即时效果的怪兽卡
function s.cfilter(c)
	return c:IsOriginalEffectProperty(s.quick_filter) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsFaceupEx()
end
-- 特殊召唤条件函数，检查是否满足特殊召唤的条件
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上或墓地是否存在满足条件的怪兽卡
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
end
-- 特殊召唤时的操作函数，支付一半基本分
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 支付当前玩家基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 融合素材限制函数，用于限制该卡不能作为融合召唤的素材
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 效果免疫过滤器，用于判断是否免疫对方怪兽效果的影响
function s.efilter(e,re)
	-- 判断是否为当前回合玩家发动的效果
	if Duel.GetTurnPlayer()==e:GetHandlerPlayer() and e:GetHandlerPlayer()~=re:GetOwnerPlayer()
		and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) then
		-- 获取连锁发动位置信息
		local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION) or 0
		return LOCATION_ONFIELD&loc~=0
	end
	return false
end
