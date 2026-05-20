--赫灼竜マスカレイド
-- 效果：
-- 「死狱乡」怪兽＋光·暗属性怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要融合召唤的这张卡在怪兽区域存在，对方若不支付600基本分，则不能把卡的效果发动。
-- ②：自己·对方回合，这张卡在墓地存在，对方场上有仪式·融合·同调·超量·连接怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c6855503.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为1只「死狱乡」怪兽和1只满足过滤条件（光·暗属性）的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x164),c6855503.matfilter,true)
	-- ①：只要融合召唤的这张卡在怪兽区域存在，对方若不支付600基本分，则不能把卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ACTIVATE_COST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c6855503.costcon)
	e1:SetCost(c6855503.costchk)
	e1:SetOperation(c6855503.costop)
	c:RegisterEffect(e1)
	-- ①：只要融合召唤的这张卡在怪兽区域存在，对方若不支付600基本分，则不能把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FLAG_EFFECT+6855503)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c6855503.costcon)
	e2:SetTargetRange(0,1)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，这张卡在墓地存在，对方场上有仪式·融合·同调·超量·连接怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6855503,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,6855503)
	e3:SetCondition(c6855503.spcon)
	e3:SetTarget(c6855503.sptg)
	e3:SetOperation(c6855503.spop)
	c:RegisterEffect(e3)
end
-- 过滤融合素材：光属性或暗属性怪兽
function c6855503.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 检查自身是否为融合召唤，作为支付基本分效果的适用条件
function c6855503.costcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检查对方玩家是否能支付对应的基本分（考虑场上存在多张伪装龙时叠加的支付数值）
function c6855503.costchk(e,te_or_c,tp)
	-- 获取对方场上存在的「赫灼龙 伪装龙」的数量（用于计算需要支付的基本分倍数）
	local ct=Duel.GetFlagEffect(tp,6855503)
	-- 检查对方玩家是否拥有足够支付（伪装龙数量 * 600）的基本分
	return Duel.CheckLPCost(tp,ct*600)
end
-- 执行支付基本分的操作
function c6855503.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 扣除对方玩家600点基本分
	Duel.PayLPCost(tp,600)
end
-- 过滤对方场上表侧表示的仪式、融合、同调、超量、连接怪兽
function c6855503.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 检查是否满足墓地特殊召唤效果的发动条件
function c6855503.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧表示的仪式、融合、同调、超量或连接怪兽
	return Duel.IsExistingMatchingCard(c6855503.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤效果的发动准备，检查自身是否能特殊召唤并注册操作信息
function c6855503.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表明将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行墓地特殊召唤效果，将自身特殊召唤并添加离场除外的限制
function c6855503.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍存在于墓地，并尝试以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
