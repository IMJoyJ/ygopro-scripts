--叛逆者エト
-- 效果：
-- 这张卡不能通常召唤。「叛逆者 埃图」1回合1次在持有以下效果的怪兽卡在对方的场上或墓地存在，把基本分支付一半的场合才能从手卡·墓地特殊召唤。
-- ●需在有效果发动时连锁并在手卡或怪兽区域发动的效果
-- ①：这张卡的特殊召唤不会被无效化。
-- ②：这张卡只要在怪兽区域存在，不能作为融合·同调·超量·连接召唤的素材，自己回合内不受对方场上发动的怪兽的效果影响。
local s,id,o=GetID()
-- 为「叛逆者 埃图」注册全部相关规则效果：设置不能通常召唤的特殊召唤条件；注册从手卡·墓地进行的1回合1次特殊召唤手续（条件：对方场上或墓地存在持有指定效果的怪兽，并支付一半LP）；使这张卡的特殊召唤不会被无效化；在怪兽区域存在时不能作为融合·同调·超量·连接召唤的素材；自己回合内不受对方场上发动的怪兽效果影响。
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
	-- ①：这张卡的特殊召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- ②：这张卡只要在怪兽区域存在，不能作为融合·同调·超量·连接召唤的素材（此处实现为不能作为同调召唤的素材）。
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
-- 判断一个效果是否为『需在有效果发动时连锁并在手卡或怪兽区域发动的效果』：要求该效果的触发事件为效果发动（EVENT_CHAINING）或成为对象（EVENT_BECOME_TARGET），类型包含诱发即时效果（EFFECT_TYPE_QUICK_O或EFFECT_TYPE_QUICK_F），且效果生效范围在手卡或怪兽区域。
function s.quick_filter(e)
	return (e:GetCode()==EVENT_CHAINING or e:GetCode()==EVENT_BECOME_TARGET) and e:IsHasType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F) and e:IsHasRange(LOCATION_HAND+LOCATION_MZONE)
end
-- 判断一张卡是否为『持有以下效果的怪兽卡』：该卡的原始效果中存在满足s.quick_filter的效果，原本类型为怪兽，且当前为公开状态（场上表侧表示或在墓地），用于检索对方场上·墓地存在的符合条件的怪兽卡。
function s.cfilter(c)
	return c:IsOriginalEffectProperty(s.quick_filter) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsFaceupEx()
end
-- 特殊召唤规则的条件：当c为nil时（规则询问）返回true；否则要求此卡控制者场上有可用的主要怪兽区域，且对方场上或墓地存在至少1张满足s.cfilter的怪兽卡。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查此卡控制者（tp）的主要怪兽区域是否存在空位，确保有格子可以进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 以tp为视角检索对方场上或墓地（s=0表示不含我方区域，o=LOCATION_ONFIELD+LOCATION_GRAVE）是否存在至少1张满足s.cfilter的怪兽卡，以证明对方场上或墓地存在持有指定效果的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
end
-- 特殊召唤手续的执行函数：在从手卡·墓地特殊召唤时，支付基本分一半作为特殊召唤代价。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 将tp的当前LP数值除以2后向下取整，作为COST支付，实现『把基本分支付一半』。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 作为融合素材限制的Value函数：判断本次特殊召唤方式是否为融合召唤（sumtype==SUMMON_TYPE_FUSION），是则此卡不能作为融合召唤的素材。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 免疫效果的判定函数：仅当满足以下全部条件时返回true，使此卡不受该效果影响——此卡控制者处于自己的回合、效果持有者为此卡控制者的对手、该效果是已发动的怪兽效果、且该效果的发动位置在场上（通过当前连锁信息获取）；否则不免疫。
function s.efilter(e,re)
	-- 判定免疫的玩家与效果条件：当前是此卡控制者的回合，且该效果的持有者不是此卡控制者（即对方效果），同时该效果是已发动的怪兽效果。
	if Duel.GetTurnPlayer()==e:GetHandlerPlayer() and e:GetHandlerPlayer()~=re:GetOwnerPlayer()
		and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) then
		-- 获取当前连锁中效果发动的位置（CHAININFO_TRIGGERING_LOCATION），若不存在则视为0；随后将其与场上位置按位与，用于判断该效果是否从场上发动，以限定『对方场上发动的怪兽的效果』。
		local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION) or 0
		return LOCATION_ONFIELD&loc~=0
	end
	return false
end
