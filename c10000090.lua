--ラーの翼神竜－不死鳥
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
-- ②：这张卡不受其他卡的效果影响。
-- ③：支付1000基本分才能发动。场上1只怪兽送去墓地。
-- ④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
function c10000090.initial_effect(c)
	-- 将卡片10000010的代码添加到当前卡片的代码列表中。
	aux.AddCodeList(c,10000010)
	c:EnableReviveLimit()
	-- 创建并注册一个效果，用于设置特殊召唤条件。该效果不可禁用且不可复制。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 创建并注册一个效果，当“太阳神之翼神龙”从场上送去自己墓地时，特殊召唤这张卡。①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
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
	-- 创建并注册一个效果，使这张卡不受其他卡的效果影响。②：这张卡不受其他卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c10000090.efilter)
	c:RegisterEffect(e3)
	-- 创建并注册一个效果，支付1000基本分才能将场上的一只怪兽送去墓地。③：支付1000基本分才能发动。场上1只怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10000090,1))  --"选场上1只怪兽送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c10000090.tgcost)
	e4:SetTarget(c10000090.tgtg)
	e4:SetOperation(c10000090.tgop)
	c:RegisterEffect(e4)
	-- 创建并注册一个效果，在结束阶段将这张卡送去墓地，并从手卡、卡组或墓地特殊召唤一只“太阳神之翼神龙-球体形”。④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
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
-- 定义一个过滤函数，用于检查卡片是否是代码为10000010的“太阳神之翼神龙”，且属于当前玩家控制，并且之前在场上存在过。
function c10000090.cfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义一个特殊召唤条件，确保只有当墓地中没有这张卡本身，并且存在满足cfilter条件的“太阳神之翼神龙”时才能发动效果。
function c10000090.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c10000090.cfilter,1,nil,tp)
end
-- 定义一个特殊召唤目标选择函数，设置连锁限制并设定操作信息为特殊召唤当前卡片。
function c10000090.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 禁止新的连锁效果的发生。
	Duel.SetChainLimit(aux.FALSE)
	-- 设置操作信息，表明正在进行特殊召唤，目标是当前卡片，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义一个特殊召唤执行函数，如果满足条件则特殊召唤这张卡并完成流程。
function c10000090.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡是否与效果相关联，并且成功特殊召唤了这张卡。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 定义一个过滤函数，用于判断目标怪兽的效果是否不受王家长眠之谷的影响。
function c10000090.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 定义一个支付基本分数的函数，检查玩家是否能支付1000点生命值，并进行支付。
function c10000090.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否能够支付1000点生命值。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让当前玩家支付1000点生命值。
	Duel.PayLPCost(tp,1000)
end
-- 定义一个目标选择函数，用于选择要送去墓地的怪兽，并设置操作信息为将一张卡送去墓地。
function c10000090.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在能够被送去墓地的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，表明正在进行送去墓地的效果，目标是所有玩家的怪兽区域，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 定义一个执行函数，用于选择要送去墓地的怪兽并将其送去墓地。
function c10000090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择一张能够被送去墓地的卡片。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 高亮显示所选的卡片。
		Duel.HintSelection(g)
		-- 将所选的卡片送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义一个过滤函数，用于检查卡片是否是代码为10000080的“太阳神之翼神龙-球体形”，并且可以被特殊召唤。
function c10000090.spfilter(c,e,tp)
	return c:IsCode(10000080) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 定义一个特殊召唤目标选择函数，设置操作信息为送去墓地和特殊召唤，并限制连锁。
function c10000090.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明正在进行送去墓地的效果，目标是当前卡片，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置操作信息，表明正在进行特殊召唤，目标是不确定的，位置包括手牌、卡组和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义一个执行函数，用于将这张卡送去墓地，并从手卡、卡组或墓地特殊召唤一只“太阳神之翼神龙-球体形”。
function c10000090.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡是否与效果相关联，并且成功送去墓地，且当前卡在墓地。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 如果怪兽区没有空格则直接返回。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌、卡组或墓地中选择一只满足条件的“太阳神之翼神龙-球体形”。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10000090.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤所选的卡片。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
