--バランサーロード
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，支付1000基本分才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只电子界族怪兽召唤。
-- ②：这张卡被除外的场合才能发动。从手卡把1只4星以下的怪兽特殊召唤。
function c8567955.initial_effect(c)
	-- ①：1回合1次，支付1000基本分才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只电子界族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8567955,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c8567955.sumcost)
	e1:SetTarget(c8567955.sumtg)
	e1:SetOperation(c8567955.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从手卡把1只4星以下的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8567955,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,8567955)
	e2:SetTarget(c8567955.sptg)
	e2:SetOperation(c8567955.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的Cost（支付1000基本分）
function c8567955.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- ①号效果的发动准备与检查
function c8567955.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以通常召唤以及是否可以追加通常召唤
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否尚未适用过该追加召唤效果
		and Duel.GetFlagEffect(tp,8567955)==0 end
end
-- ①号效果的处理（增加电子界族怪兽的召唤机会）
function c8567955.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已适用过该效果则不再处理
	if Duel.GetFlagEffect(tp,8567955)~=0 then return end
	-- 这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只电子界族怪兽召唤。从手卡把1只4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(8567955,2))  --"使用「均衡负载王」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置追加召唤的怪兽必须是电子界族
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERSE))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将追加召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合已适用该效果的标记
	Duel.RegisterFlagEffect(tp,8567955,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤手卡中等级4以下的可以特殊召唤的怪兽
function c8567955.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备与特殊召唤目标检查
function c8567955.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c8567955.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②号效果的处理（从手卡特殊召唤怪兽）
function c8567955.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c8567955.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
