--ラーの翼神竜－不死鳥
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：这张卡在墓地存在的状态，「太阳神之翼神龙」从场上送去自己墓地的场合发动（不能对应这个发动把效果发动）。这张卡特殊召唤。
-- ②：这张卡不受其他卡的效果影响。
-- ③：支付1000基本分才能发动。场上1只怪兽送去墓地。
-- ④：结束阶段发动。这张卡送去墓地，从自己的手卡·卡组·墓地把1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤。
function c10000090.initial_effect(c)
	-- 记录这张卡上记载了卡名「太阳神之翼神龙」的事实
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
-- 过滤函数：过滤出自己场上送去墓地的「太阳神之翼神龙」
function c10000090.cfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动条件：自己场上的「太阳神之翼神龙」送去自己墓地，且此卡在墓地存在
function c10000090.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c10000090.cfilter,1,nil,tp)
end
-- 效果目标：检查此卡是否可以特殊召唤，设置当前连锁玩家不能把效果发动的连锁限制，并设置特殊召唤自身的连锁操作信息
function c10000090.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁限制，使玩家不能对应这个发动把效果发动
	Duel.SetChainLimit(aux.FALSE)
	-- 设置当前处理的连锁操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡在墓地存在，则无视召唤条件与苏生限制特殊召唤此卡，并完成正规召唤程序
function c10000090.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡与当前效果相关联，则无视召唤条件与苏生限制特殊召唤自身，并判断特殊召唤是否成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 效果过滤：过滤不受除了此卡以外的其他卡的效果影响的判定条件
function c10000090.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 发动代价：检查并支付1000基本分
function c10000090.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让发动效果的玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果目标：检查场上是否存在可以送去墓地的怪兽，并设置送墓的连锁操作信息
function c10000090.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只可以被送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置当前处理的连锁操作信息为将双方场上的1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 效果处理：让玩家选择双方场上1只可以送去墓地的怪兽并将其送去墓地
function c10000090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息以选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择双方场上1张可以送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为选择的卡片显示被选为操作对象的动画效果
		Duel.HintSelection(g)
		-- 因效果将选择的卡片送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数：过滤出符合特殊召唤条件的「太阳神之翼神龙-球体形」
function c10000090.spfilter(c,e,tp)
	return c:IsCode(10000080) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果目标：设置此卡送去墓地以及特殊召唤怪兽的连锁操作信息
function c10000090.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁操作信息为将此卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置当前处理的连锁操作信息为特殊召唤1张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：将此卡送去墓地，并从自己的手卡、卡组、墓地选择1只「太阳神之翼神龙-球体形」无视召唤条件特殊召唤
function c10000090.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡与当前效果相关联，则将其因效果送去墓地，并确认是否成功送去墓地且在墓地存在
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 检查自己场上是否有空余的怪兽区域，若没有则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家发送提示信息以选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡、卡组、墓地选择1张不受「王家长眠之谷」影响且符合特殊召唤条件的卡片
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10000090.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 无视召唤条件将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
