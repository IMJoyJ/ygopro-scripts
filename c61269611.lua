--ダイナレスラー・イグアノドラッカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡以外的1只恐龙族怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：把自己场上1只恐龙族怪兽解放，以原本卡名和那只怪兽不同的自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c61269611.initial_effect(c)
	-- ①：从手卡把这张卡以外的1只恐龙族怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61269611,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61269611)
	e1:SetCost(c61269611.spcost1)
	e1:SetTarget(c61269611.sptg1)
	e1:SetOperation(c61269611.spop1)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只恐龙族怪兽解放，以原本卡名和那只怪兽不同的自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61269611,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61269612)
	e2:SetCost(c61269611.spcost2)
	e2:SetTarget(c61269611.sptg2)
	e2:SetOperation(c61269611.spop2)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可丢弃的恐龙族怪兽
function c61269611.costfilter1(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsDiscardable()
end
-- 效果①的发动代价：从手卡把这张卡以外的1只恐龙族怪兽丢弃
function c61269611.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61269611.costfilter1,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手卡中1只除这张卡以外的恐龙族怪兽丢弃
	Duel.DiscardHand(tp,c61269611.costfilter1,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及这张卡是否能特殊召唤
function c61269611.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤
function c61269611.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上可解放的恐龙族怪兽，且该怪兽解放后有空位，并且墓地存在原本卡名不同的「恐龙摔跤手」怪兽
function c61269611.costfilter2(c,e,tp)
	-- 检查该卡是否为恐龙族，且解放该卡后自己场上是否有可用的怪兽区域
	return c:IsRace(RACE_DINOSAUR) and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己墓地是否存在原本卡名与被解放怪兽不同的「恐龙摔跤手」怪兽
		and Duel.IsExistingTarget(c61269611.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤墓地中原本卡名与解放怪兽不同、且可以守备表示特殊召唤的「恐龙摔跤手」怪兽
function c61269611.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x11a) and not c:IsOriginalCodeRule(mc:GetOriginalCodeRule()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动代价：把自己场上1只恐龙族怪兽解放
function c61269611.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的满足条件的恐龙族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c61269611.costfilter2,1,nil,e,tp) end
	-- 玩家选择自己场上1只满足条件的恐龙族怪兽
	local g=Duel.SelectReleaseGroup(tp,c61269611.costfilter2,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动准备：选择自己墓地1只原本卡名与解放怪兽不同的「恐龙摔跤手」怪兽为对象，并设置特殊召唤的操作信息
function c61269611.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mc=e:GetLabelObject()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c61269611.spfilter(chkc,e,tp,mc) end
	if chk==0 then return true end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只原本卡名与解放怪兽不同的「恐龙摔跤手」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61269611.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mc)
	-- 设置特殊召唤的操作信息，表示将特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的墓地怪兽守备表示特殊召唤
function c61269611.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
