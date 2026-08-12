--RAMクラウダー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c9190563.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上1只怪兽解放，以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9190563,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,9190563)
	e1:SetCost(c9190563.spcost)
	e1:SetTarget(c9190563.sptg)
	e1:SetOperation(c9190563.spop)
	c:RegisterEffect(e1)
end
-- 过滤可解放的怪兽，若怪兽区无空位，则必须解放自己主要怪兽区的怪兽以腾出位置
function c9190563.cfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 发动代价处理，解放自己场上1只怪兽
function c9190563.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家主要怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查玩家场上是否存在可解放的怪兽，且解放后有足够的怪兽区域进行特殊召唤
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c9190563.cfilter,1,nil,ft,tp) end
	-- 让玩家选择1只满足条件的怪兽作为解放的代价
	local g=Duel.SelectReleaseGroup(tp,c9190563.cfilter,1,1,nil,ft,tp)
	-- 将选择的怪兽作为代价解放
	Duel.Release(g,REASON_COST)
end
-- 过滤自己墓地中可以特殊召唤的电子界族怪兽
function c9190563.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择处理
function c9190563.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c9190563.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在可以特殊召唤的电子界族怪兽
	if chk==0 then return Duel.IsExistingTarget(c9190563.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只电子界族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9190563.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst()==e:GetHandler() then
		e:GetHandler():ReleaseEffectRelation(e)
	end
	-- 设置效果处理信息，表示该效果包含特殊召唤目标卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，将作为对象的怪兽特殊召唤
function c9190563.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToChain() or (tc==c and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetReasonEffect()==e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
