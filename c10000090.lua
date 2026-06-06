--ラーの翼神竜－不死鳥
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
-- ②：这张卡不受其他卡的效果影响。
-- ③：支付1000基本分才能发动。场上1只怪兽送去墓地。
-- ④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
function c10000090.initial_effect(c)
	-- 将「太阳神之翼神龙」的卡片密码写入此卡的关联卡片列表
	aux.AddCodeList(c,10000010)
	c:EnableReviveLimit()
	-- 特殊召唤条件限制
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 在墓地存在时，自己场上的「太阳神之翼神龙」送去墓地场合触发的特殊召唤效果（不能连锁）
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
	-- 此卡不受其他卡的效果影响的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c10000090.efilter)
	c:RegisterEffect(e3)
	-- 支付1000基本分，将场上1只怪兽送去墓地的效果
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10000090,1))  --"选场上1只怪兽送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c10000090.tgcost)
	e4:SetTarget(c10000090.tgtg)
	e4:SetOperation(c10000090.tgop)
	c:RegisterEffect(e4)
	-- 结束阶段将自身送去墓地，并从手卡·卡组·墓地无视召唤条件特殊召唤「太阳神之翼神龙-球体形」的效果
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
-- 检测送去墓地的卡是否为自己场上「太阳神之翼神龙」的过滤函数
function c10000090.cfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤效果的发动条件判定函数
function c10000090.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c10000090.cfilter,1,nil,tp)
end
-- 特殊召唤效果的判定与限制函数
function c10000090.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 限制任何卡片或效果连锁此效果的发动
	Duel.SetChainLimit(aux.FALSE)
	-- 设置效果分类为特殊召唤，并指定特殊召唤此卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行操作函数
function c10000090.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤此卡，并判断是否成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 效果不受影响的过滤函数（排除此卡自身拥有的效果）
function c10000090.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 送去墓地效果的Cost函数（支付1000基本分）
function c10000090.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 送去墓地效果的目标判定函数
function c10000090.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置效果分类为送去墓地，目标为场上任意1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 送去墓地效果的执行操作函数
function c10000090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 声明选中的怪兽以示提示
		Duel.HintSelection(g)
		-- 将被选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 特殊召唤目标的过滤函数（「太阳神之翼神龙-球体形」）
function c10000090.spfilter(c,e,tp)
	return c:IsCode(10000080) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤「太阳神之翼神龙-球体形」的目标判定函数
function c10000090.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果分类为送去墓地，目标为此卡自身
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置效果分类为特殊召唤，并指定特殊召唤来源为手卡·卡组·墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 结束阶段特殊召唤「太阳神之翼神龙-球体形」的执行操作函数
function c10000090.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡送去墓地，并判断是否成功送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 检查玩家场上的怪兽区域空位是否足够
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地中选择1只「太阳神之翼神龙-球体形」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10000090.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤选中的怪兽
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
