--無限起動トレンチャー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以「无限起动 挖沟机」以外的自己墓地1只5星以下的「无限起动」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c61912252.initial_effect(c)
	-- ①：把自己场上1只机械族·地属性怪兽解放才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61912252,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61912252)
	e1:SetCost(c61912252.spcost)
	e1:SetTarget(c61912252.sptg)
	e1:SetOperation(c61912252.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「无限起动 挖沟机」以外的自己墓地1只5星以下的「无限起动」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61912252,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,61912253)
	-- 将墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c61912252.sptg2)
	e2:SetOperation(c61912252.spop2)
	c:RegisterEffect(e2)
end
-- 过滤场上可解放的机械族·地属性怪兽，且解放后能腾出怪兽区域
function c61912252.cfilter(c,tp)
	-- 检查卡片是否为机械族·地属性，且该卡解放后能使该玩家场上有可用的怪兽区域
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动代价：解放自己场上1只机械族·地属性怪兽
function c61912252.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动代价：场上是否存在至少1只可解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c61912252.cfilter,1,nil,tp) end
	-- 玩家选择1只满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c61912252.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c61912252.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将手卡的这张卡守备表示特殊召唤
function c61912252.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤墓地中「无限起动 挖沟机」以外的5星以下的「无限起动」怪兽，且该怪兽可以特殊召唤
function c61912252.spfilter2(c,e,tp)
	return c:IsLevelBelow(5) and c:IsSetCard(0x127) and not c:IsCode(61912252)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备：选择墓地中1只满足条件的怪兽作为对象
function c61912252.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c61912252.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽（排除自身）
		and Duel.IsExistingTarget(c61912252.spfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61912252.spfilter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁信息，表示该效果包含将选中的怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽守备表示特殊召唤
function c61912252.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
