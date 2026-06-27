--ラーの翼神竜－不死鳥
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
-- ②：这张卡不受其他卡的效果影响。
-- ③：支付1000基本分才能发动。场上1只怪兽送去墓地。
-- ④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
function c10000090.initial_effect(c)
	-- 声明关联的太阳神之翼神龙卡片
	aux.AddCodeList(c,10000010)
	c:EnableReviveLimit()
	-- 用这张卡的效果才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动。这张卡特殊召唤。
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
-- 过滤被送去墓地的我方场上的太阳神之翼神龙
function c10000090.cfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤条件：太阳神之翼神龙被送入我方墓地时触发
function c10000090.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c10000090.cfilter,1,nil,tp)
end
-- 特殊召唤效果的目标锁定：由于效果为强制触发，因而直接返回真
function c10000090.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 不能对应这个效果的发动把卡的效果发动（禁止连锁）
	Duel.SetChainLimit(aux.FALSE)
	-- 声明将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际操作
function c10000090.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将自身特殊召唤到场上，并判断是否特召成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 效果免疫的过滤器（不受此卡以外的其他卡的效果影响）
function c10000090.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 送墓效果的Cost：支付1000点生命值
function c10000090.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000点生命值
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000点生命值
	Duel.PayLPCost(tp,1000)
end
-- 送墓效果的目标选择：检查是否存在可被送墓的怪兽
function c10000090.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 声明将怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 送墓效果的实际操作
function c10000090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上的一只怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 在场上展示被选中的怪兽
		Duel.HintSelection(g)
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤用于特殊召唤的「太阳神之翼神龙-球体形」
function c10000090.spfilter(c,e,tp)
	return c:IsCode(10000080) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 阶段结束效果的准备工作：锁定自身的送墓与球体形的特召
function c10000090.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 声明将本卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 声明从手卡·卡组·墓地特殊召唤球体形的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 阶段结束效果的实际操作
function c10000090.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将自身送去墓地，并检查是否已在墓地中存在
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 检查特殊召唤时自己场上是否有怪兽位置空缺
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择手卡·卡组·墓地中的1只「太阳神之翼神龙-球体形」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10000090.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 无视召唤条件在场上特殊召唤「太阳神之翼神龙-球体形」
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
