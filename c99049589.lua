--デストーイ・リペアー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只「魔玩具」融合怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以从自己墓地选1只「毛绒动物」怪兽或者「锋利小鬼」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「毛绒动物」怪兽或者「锋利小鬼」怪兽特殊召唤。
function c99049589.initial_effect(c)
	-- ①：以自己墓地1只「魔玩具」融合怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以从自己墓地选1只「毛绒动物」怪兽或者「锋利小鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99049589,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,99049589)
	e1:SetTarget(c99049589.target)
	e1:SetOperation(c99049589.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「毛绒动物」怪兽或者「锋利小鬼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99049589,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,99049589)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c99049589.sptg)
	e2:SetOperation(c99049589.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以回到额外卡组的「魔玩具」融合怪兽
function c99049589.filter(c)
	return c:IsSetCard(0xad) and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
-- ①效果的发动准备，检查墓地是否有合法的「魔玩具」融合怪兽，并进行取对象和设置操作信息
function c99049589.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99049589.filter(chkc) end
	-- 检查自己墓地是否存在至少1只可以回到额外卡组的「魔玩具」融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c99049589.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择作为效果对象的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只「魔玩具」融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c99049589.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 过滤可以特殊召唤的「毛绒动物」或「锋利小鬼」怪兽
function c99049589.spfilter(c,e,tp)
	return c:IsSetCard(0xa9,0xc3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理，将对象怪兽送回额外卡组，并可选地从墓地特殊召唤1只「毛绒动物」或「锋利小鬼」怪兽
function c99049589.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍对应效果，并将其送回额外卡组，确认其已成功回到额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「毛绒动物」或「锋利小鬼」怪兽（受王家之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c99049589.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择进行后续的特殊召唤效果
		and Duel.SelectYesNo(tp,aux.Stringid(99049589,2)) then  --"是否从墓地特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理不与回到额外卡组同时进行（错时点）
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只满足条件的「毛绒动物」或「锋利小鬼」怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99049589.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动准备，检查怪兽区域空位及手卡中是否有可特召的怪兽，并设置操作信息
function c99049589.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在可以特殊召唤的「毛绒动物」或「锋利小鬼」怪兽
		and Duel.IsExistingMatchingCard(c99049589.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理，从手卡特殊召唤1只「毛绒动物」或「锋利小鬼」怪兽
function c99049589.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡选择1只满足条件的「毛绒动物」或「锋利小鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c99049589.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
