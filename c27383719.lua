--S－Force ラプスウェル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：从手卡把1张「治安战警队」卡除外才能发动。自己的「治安战警队」怪兽的正对面的对方怪兽全部破坏。
function c27383719.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤成功的场合，以「治安战警队 拉普斯韦妖」以外的自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27383719,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27383719)
	e1:SetTarget(c27383719.sptg)
	e1:SetOperation(c27383719.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：从手卡把1张「治安战警队」卡除外才能发动。自己的「治安战警队」怪兽的正对面的对方怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(27383719,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27383720)
	e2:SetCost(c27383719.descost)
	e2:SetTarget(c27383719.destg)
	e2:SetOperation(c27383719.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，筛选自己墓地中除「治安战警队 拉普斯韦妖」以外、可特殊召唤的「治安战警队」怪兽
function c27383719.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and not c:IsCode(27383719)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的Target函数，检测怪兽区空格并选择自己墓地1只符合spfilter条件的怪兽作为对象，设置特殊召唤操作信息
function c27383719.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27383719.spfilter(chkc,e,tp) end
	-- 发动条件检测时，检查自己场上是否有可用的主要怪兽区域空格
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己墓地是否存在至少1只满足spfilter条件且可作为对象的怪兽
		and Duel.IsExistingTarget(c27383719.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在自己墓地选择1只满足spfilter条件的怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,c27383719.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明将特殊召唤对象卡g中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的Operation函数，确认对象与效果关联后将其特殊召唤
function c27383719.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的第1张对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- Cost过滤函数，筛选可从手卡作为代价除外的「治安战警队」卡，或适用代替除外效果(如55049722墓地除外、11642993卡组送墓)的卡片
function c27383719.costfilter(c,e,tp)
	if c:IsHasEffect(55049722,tp) then
		return e:GetHandler():IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	elseif c:IsHasEffect(11642993,tp) then
		return e:GetHandler():IsSetCard(0x156) and not c:IsCode(11642993)
			and c:IsSetCard(0x156) and c:IsAbleToGraveAsCost()
	elseif c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	end
end
-- ②效果的Cost函数，选择满足条件的「治安战警队」卡作为代价除外，或在适用代替效果时改为支付墓地除外或卡组送墓的代替代价
function c27383719.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检测时，检查手卡·墓地·卡组中是否存在满足costfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取手卡·墓地·卡组中所有满足costfilter条件的卡片组
	local cg=Duel.GetMatchingGroup(c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if cg:IsExists(Card.IsHasEffect,1,nil,11642993,tp) then
		-- 向自己发送选择提示信息：“请选择要操作的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	else
		-- 向自己发送选择提示信息：“请选择要除外的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	end
	-- 让自己从手卡·墓地·卡组中选择1张满足costfilter条件的卡作为发动代价
	local tg=Duel.SelectMatchingCard(tp,c27383719.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(11642993,tp)
	if te then
		-- 向全场展示「治安战警队多世界排序」(11642993)的卡片发动提示以表明适用其代替效果
		Duel.Hint(HINT_CARD,0,11642993)
		te:UseCountLimit(tp)
		-- 作为代价代替，将选中的卡送去墓地
		Duel.SendtoGrave(tg,REASON_COST+REASON_REPLACE)
	else
		local te2=tg:GetFirst():IsHasEffect(55049722,tp)
		if te2 then
			te2:UseCountLimit(tp)
			-- 作为代价代替，将选中的卡以表侧表示除外
			Duel.Remove(tg,POS_FACEUP,REASON_COST+REASON_REPLACE)
		else
			-- 作为发动代价，将选中的手卡以表侧表示除外
			Duel.Remove(tg,POS_FACEUP,REASON_COST)
		end
	end
end
-- 过滤函数，筛选自己场上怪兽区域表侧表示存在的「治安战警队」怪兽
function c27383719.ggfilter(c,tp)
	return c:IsSetCard(0x156) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 过滤函数，判断目标怪兽所在同纵列的卡片组中是否存在满足ggfilter条件的己方「治安战警队」怪兽
function c27383719.desfilter(c,tp)
	local g=c:GetColumnGroup()
	return g:IsExists(c27383719.ggfilter,1,nil,tp)
end
-- ②效果的Target函数，筛选所有处于己方「治安战警队」怪兽正对面的对方怪兽，检查数量大于0并设置破坏操作信息
function c27383719.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方怪兽区域中所有满足desfilter条件的怪兽组
	local g=Duel.GetMatchingGroup(c27383719.desfilter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>0 end
	-- 设置操作信息，声明将破坏符合条件的对方怪兽组g
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②效果的Operation函数，再次获取所有位于己方「治安战警队」怪兽正对面的对方怪兽并将其全部破坏
function c27383719.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方怪兽区域中满足desfilter条件的怪兽组
	local g=Duel.GetMatchingGroup(c27383719.desfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 以效果将怪兽组g中的全部对方怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
