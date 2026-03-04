--ラーの翼神竜－不死鳥
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
-- ②：这张卡不受其他卡的效果影响。
-- ③：支付1000基本分才能发动。场上1只怪兽送去墓地。
-- ④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
function c10000090.initial_effect(c)
	-- 为卡片注册与「太阳神之翼神龙」相关的代码列表，用于后续效果判定
	aux.AddCodeList(c,10000010)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10000090,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c10000090.spcon1)
	e2:SetTarget(c10000090.sptg1)
	e2:SetOperation(c10000090.spop1)
	c:RegisterEffect(e2)
	-- ②：这张卡不受其他卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c10000090.efilter)
	c:RegisterEffect(e3)
	-- ③：支付1000基本分才能发动。场上1只怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10000090,1))  --"选场上1只怪兽送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c10000090.tgcost)
	e4:SetTarget(c10000090.tgtg)
	e4:SetOperation(c10000090.tgop)
	c:RegisterEffect(e4)
	-- ④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(10000090,2))  --"把1只「太阳神之翼神龙-球体形」特殊召唤"
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetTarget(c10000090.sptg2)
	e5:SetOperation(c10000090.spop2)
	c:RegisterEffect(e5)
end
-- 用于判断是否满足特殊召唤条件的过滤函数，检查是否有「太阳神之翼神龙」从场上送去墓地
function c10000090.cfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断是否满足特殊召唤条件，即是否有「太阳神之翼神龙」从场上送去墓地且不是自己
function c10000090.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c10000090.cfilter,1,nil,tp)
end
-- 设置特殊召唤效果的目标，准备将自己特殊召唤
function c10000090.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁限制为无，允许该效果无限制地连锁
	Duel.SetChainLimit(aux.FALSE)
	-- 设置操作信息，表示将特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将自己特殊召唤到场上
function c10000090.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否成功特殊召唤并完成程序
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 设置效果免疫函数，使该卡不受其他卡的效果影响
function c10000090.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 支付LP的费用函数，检查并支付1000基本分
function c10000090.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置送去墓地效果的目标，准备选择场上怪兽送去墓地
function c10000090.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，表示将场上怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 执行送去墓地操作，选择并送去墓地
function c10000090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择场上1只可以送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选中的怪兽作为对象
		Duel.HintSelection(g)
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 用于判断是否可以特殊召唤「太阳神之翼神龙-球体形」的过滤函数
function c10000090.spfilter(c,e,tp)
	return c:IsCode(10000080) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标，准备将「太阳神之翼神龙-球体形」特殊召唤
function c10000090.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将自己送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示将从手牌/卡组/墓地特殊召唤「太阳神之翼神龙-球体形」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行特殊召唤操作，将「太阳神之翼神龙-球体形」特殊召唤
function c10000090.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否成功将自己送去墓地并满足特殊召唤条件
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 检查场上是否有足够的召唤位置
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的「太阳神之翼神龙-球体形」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的「太阳神之翼神龙-球体形」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10000090.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「太阳神之翼神龙-球体形」特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
