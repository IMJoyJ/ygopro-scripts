--ファーニマル・シープ
-- 效果：
-- 「毛绒动物·绵羊」的②的效果1回合只能使用1次。
-- ①：自己场上有「毛绒动物·绵羊」以外的「毛绒动物」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：让这张卡以外的自己场上1只「毛绒动物」怪兽回到持有者手卡才能发动。从自己的手卡·墓地选1只「锋利小鬼」怪兽特殊召唤。
function c98280324.initial_effect(c)
	-- ①：自己场上有「毛绒动物·绵羊」以外的「毛绒动物」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c98280324.spcon)
	c:RegisterEffect(e1)
	-- 「毛绒动物·绵羊」的②的效果1回合只能使用1次。②：让这张卡以外的自己场上1只「毛绒动物」怪兽回到持有者手卡才能发动。从自己的手卡·墓地选1只「锋利小鬼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,98280324)
	e2:SetCost(c98280324.spcost)
	e2:SetTarget(c98280324.sptg)
	e2:SetOperation(c98280324.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「毛绒动物·绵羊」以外的「毛绒动物」怪兽
function c98280324.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa9) and not c:IsCode(98280324)
end
-- 特殊召唤规则的条件：怪兽区域有空位，且自己场上存在「毛绒动物·绵羊」以外的「毛绒动物」怪兽
function c98280324.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件的怪兽（「毛绒动物·绵羊」以外的「毛绒动物」怪兽）
		and Duel.IsExistingMatchingCard(c98280324.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件（代价）：自己场上表侧表示、能回到手卡的「毛绒动物」怪兽，且在怪兽区没有空位时必须是主要怪兽区域的怪兽
function c98280324.cfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0xa9) and c:IsAbleToHandAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 效果②的发动代价：让这张卡以外的自己场上1只「毛绒动物」怪兽回到持有者手卡
function c98280324.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价合法性检查：怪兽区域数量大于-1（若为0则必须通过弹回主要怪兽区的怪兽来腾出空位），且存在可作为代价弹回手卡的怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c98280324.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),ft) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1只自己场上除这张卡以外的满足条件的「毛绒动物」怪兽
	local g=Duel.SelectMatchingCard(tp,c98280324.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),ft)
	-- 将选中的怪兽作为发动代价送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 过滤条件：手卡或墓地中可以特殊召唤的「锋利小鬼」怪兽
function c98280324.spfilter(c,e,tp)
	return c:IsSetCard(0xc3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查手卡或墓地是否存在可特殊召唤的「锋利小鬼」怪兽，并设置特殊召唤的操作信息
function c98280324.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少1只可以特殊召唤的「锋利小鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98280324.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理：从自己的手卡·墓地选1只「锋利小鬼」怪兽特殊召唤
function c98280324.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只满足条件且不受「王家之谷」影响的「锋利小鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c98280324.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
