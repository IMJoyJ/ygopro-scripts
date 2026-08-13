--混沌核
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只暗属性怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以除外的1只自己的「混沌壳」为对象才能发动。那只怪兽特殊召唤。
-- ③：表侧表示的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 定义混沌核的初始效果函数：依次注册特殊召唤条件、①的起动效果（手牌特召并附加自肃）、②的诱发效果（特召除外区的「混沌壳」），以及③的离场除外重定向。
function s.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：从自己的手卡·墓地把1只暗属性怪兽除外才能发动。这张卡从手卡特殊召唤。这个回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以除外的1只自己的「混沌壳」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 为混沌核注册③的离场除外重定向：表侧表示的这张卡从场上离开时改为除外。
	aux.AddBanishRedirect(c)
end
-- 定义特殊召唤条件判断函数：仅当特殊召唤是经由效果发动（EFFECT_TYPE_ACTIONS）时才允许，对应“用卡的效果才能特殊召唤”。
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 定义①代价的过滤条件：选择手卡·墓地的暗属性怪兽，且能够作为代价除外。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- ①的代价处理：从自己的手卡·墓地选择1只暗属性怪兽，表侧表示除外作为发动代价。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在代价检测阶段检查：自己的手卡·墓地是否存在1只可作代价除外的暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 显示选择提示，让发动者选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动者从自己的手卡·墓地选择1只满足代价过滤条件的暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的暗属性怪兽以表侧表示除外，作为①效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义①的发动目标条件：发动时确认自己怪兽区有空位，且手牌的这张卡能够用该效果特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将进行的处理为特殊召唤，对象是这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：将这张卡从手卡特殊召唤；随后给自己附加本回合额外卡组特殊召唤限制。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。②：这张卡特殊召唤成功的场合，以除外的1只自己的「混沌壳」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.spelimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃限制效果作为玩家目标效果注册到场上，在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制的判定：要特殊召唤的怪兽来自额外卡组，且不是光/暗属性的同调怪兽时，不允许特殊召唤。
function s.spelimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- 定义②的可选目标过滤：除外区的表侧表示且能够被特殊召唤的「混沌壳」。
function s.spfilter(c,e,tp)
	return c:IsCode(77312273) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②的发动条件与取对象处理：自己怪兽区有空位，且除外区存在符合条件的「混沌壳」；发动时选择其中1只为对象。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在1只可作为对象的表侧表示且可特殊召唤的「混沌壳」。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 显示选择提示，让发动者选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动者从除外区选择1只符合条件的「混沌壳」，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将进行的处理为特殊召唤，对象是所选择的「混沌壳」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②的效果处理：将对象怪兽特殊召唤到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽（「混沌壳」）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
