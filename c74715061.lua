--ストライピング・パートナー
-- 效果：
-- 这张卡不能通常召唤，用这张卡的①的效果才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上发动的怪兽的效果的发动无效的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功时，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c74715061.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的①的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：自己场上发动的怪兽的效果的发动无效的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74715061,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c74715061.spcon1)
	e2:SetTarget(c74715061.sptg1)
	e2:SetOperation(c74715061.spop1)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤成功时，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74715061,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,74715061)
	e3:SetTarget(c74715061.sptg2)
	e3:SetOperation(c74715061.spop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定：自己场上发动的怪兽效果的发动被无效
function c74715061.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁发生时的卡片位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and rp==tp
end
-- ①效果的发动目标判定：检查怪兽区域空位以及手牌的这张卡是否能特殊召唤
function c74715061.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置特殊召唤的操作信息，表示准备特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将这张卡从手牌特殊召唤，并完成正规召唤程序
function c74715061.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤，若特殊召唤成功则执行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 过滤条件：自己墓地4星以下的电子界族怪兽，且可以特殊召唤
function c74715061.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标判定：检查怪兽区域空位以及墓地是否存在符合条件的电子界族怪兽
function c74715061.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74715061.spfilter(chkc,e,tp) end
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的电子界族怪兽作为效果对象
		and Duel.IsExistingTarget(c74715061.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的电子界族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c74715061.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表示准备特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：将作为对象的怪兽特殊召唤
function c74715061.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
