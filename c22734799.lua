--三幻魔の操世者
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，从手卡把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
-- ②：丢弃1张手卡才能发动。除丢弃的卡外的1只8星以外的「三幻魔」怪兽从自己的手卡·墓地守备表示特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果的函数，注册了展示手牌中此卡并丢弃1张手牌来特殊召唤手牌「三幻魔」怪兽的起动效果，丢弃1张手牌来特殊召唤手牌·墓地「三幻魔」怪兽的起动效果，以及将墓地中此卡除来特殊召唤墓地「三幻魔」怪兽的起动效果。
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，从手卡把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡才能发动。除丢弃的卡外的1只8星以外的「三幻魔」怪兽从自己的手卡·墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 将墓地中的这张卡本身作为发动代价进行除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
end
-- 效果的发动代价检查函数，要求该卡在手牌中且未处于展示状态。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数，检查玩家手牌中是否存在可以作为效果处理而丢弃的卡，并且除去该卡外，手牌中还存在可用于特殊召唤的「三幻魔」怪兽。
function s.hfilter(c,e,tp)
	return c:IsDiscardable(REASON_EFFECT+REASON_DISCARD)
		-- 在除去作为丢弃对象的那张卡以外的手牌中，判断是否还存在可以被特殊召唤的「三幻魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 过滤函数，筛选出不属于8星的「三幻魔」系列且可守备表示特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1144) or c:IsLevel(8) then return false end
	-- 判断该卡是否可以按照指定的召唤限制要求特殊召唤到场上。
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c),POS_FACEUP_DEFENSE)
end
-- 特殊召唤辅助执行函数，根据怪兽对应的特殊召唤限制标志执行特殊召唤，并完成对应的正规召唤程序。
function s.spsummon(c,tp)
	-- 根据脚本机制判断被召唤的「三幻魔」怪兽是否需要以正规的特招限制方式特殊召唤，获取其标志。
	local flag=aux.PhantasmsSpSummonType(c)
	-- 如果成功进行了特殊召唤且该怪兽有正规特殊召唤限制，则为该怪兽完成召唤手续程序。
	if Duel.SpecialSummon(c,0,tp,tp,false,flag,POS_FACEUP_DEFENSE) and flag then
		c:CompleteProcedure()
	end
end
-- 特殊召唤效果的发动准备与检查函数，确认主要怪兽区域有空位，且手牌中存在符合条件的卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空闲的主要怪兽区域供怪兽特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动前判断手牌中是否存在可以丢弃的卡且手牌中还有其他可特殊召唤的「三幻魔」怪兽。
		and Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息，表明本效果包含在玩家场上从手牌特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理的操作信息，表明本效果包含丢弃玩家手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果的执行处理函数，让玩家先选择并丢弃1张手牌，若成功丢弃，则从手牌中选择1只符合条件的「三幻魔」怪兽进行守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local dres=0
	-- 在效果处理时进行检查，如果手牌中不存在符合条件的卡，则进行普通的无限制丢弃处理。
	if not Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		-- 在不符合条件的情况下让玩家任意丢弃1张手牌。
		dres=Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	else
		-- 让玩家丢弃1张满足过滤手牌要求的手牌卡片。
		dres=Duel.DiscardHand(tp,s.hfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil,e,tp)
	end
	if dres>0 then
		-- 在效果处理时进行检查，如果此时怪兽区域已无空位则直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家显示选择提示消息，指示其选择进行特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌中选择1张符合筛选条件的「三幻魔」怪兽卡片。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			s.spsummon(tc,tp)
		end
	else
		-- 让玩家任意丢弃1张手牌以作为失败情况下的后备处理。
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤函数，检查手牌中是否存在可作为代价丢弃的卡片，并且除该丢弃卡片之外，手牌和墓地中存在至少1只可供特殊召唤的「三幻魔」怪兽。
function s.hfilter2(c,e,tp)
	return c:IsDiscardable()
		-- 在排除所要丢弃的卡片后，在手牌和墓地里寻找是否存在可以被特殊召唤的「三幻魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 效果的Cost函数，检查是否存在可丢弃并完成特招连锁的卡，将丢弃的卡作为代价送去墓地，并将其设置为效果的目标卡。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前判断手牌中是否存在可供丢弃的卡，且除去该卡后手牌和墓地有可特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.hfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 让玩家选择并丢弃1张作为特殊召唤代价的手牌卡片。
	Duel.DiscardHand(tp,s.hfilter2,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	-- 获取在本次效果发动中，因刚才执行Cost操作而丢弃送去墓地的卡片组。
	local og=Duel.GetOperatedGroup()
	-- 将作为丢弃代价的卡片组标记并保存为当前连锁的关联对象卡片。
	Duel.SetTargetCard(og)
end
-- 特殊召唤效果的发动准备与检查函数，确认场上有空闲位置，且手牌或墓地中有可以特殊召唤的符合条件的「三幻魔」怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前玩家场上是否拥有空余的主要怪兽区格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动前判断手牌和墓地中是否存在可以被特殊召唤的「三幻魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息，表明本效果包含从手牌或墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果的执行处理函数，在有怪兽空位的前提下，让玩家从手牌或墓地选择1只除刚才丢弃的卡以外的符合条件的「三幻魔」怪兽进行守备表示特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时进行检查，如果没有空闲的主要怪兽区域则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时注册的那个作为丢弃代价的目标卡片。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then tc=nil end
	-- 向玩家显示选择提示消息，指示其选择进行特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或墓地选择1张除刚才作为代价被丢弃的卡之外、不受墓地否定效果影响的「三幻魔」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,tc,e,tp)
	local sc=g:GetFirst()
	if sc then
		s.spsummon(sc,tp)
	end
end
-- 效果的发动准备与检查函数，确认主要怪兽区域有空位，且自己墓地中存在除该卡本身之外的可以被特殊召唤的「三幻魔」怪兽。
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前玩家场上是否拥有空余的主要怪兽区域供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动前判断墓地中是否存在除了当前在墓地发动的这张卡自身以外的可被特殊召唤的「三幻魔」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置效果处理的操作信息，表明本效果包含从墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果的执行处理函数，在有怪兽空位的前提下，让玩家从自己墓地选择1只符合条件的「三幻魔」怪兽进行守备表示特殊召唤。
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时进行检查，如果场上已没有可用空位则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示消息，指示其选择进行特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1张符合筛选条件且不受墓地否定效果影响的「三幻魔」怪兽卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		s.spsummon(tc,tp)
	end
end
