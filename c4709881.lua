--星杯剣士アウラム
-- 效果：
-- 「星杯」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升自己墓地的「星遗物」怪兽种类×300。
-- ②：把这张卡所连接区1只自己的「星杯」怪兽解放，以那只怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c4709881.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求以2只「星杯」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfd),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升自己墓地的「星遗物」怪兽种类×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c4709881.atkval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡所连接区1只自己的「星杯」怪兽解放，以那只怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4709881,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4709881)
	e2:SetCost(c4709881.spcost1)
	e2:SetTarget(c4709881.sptg1)
	e2:SetOperation(c4709881.spop1)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4709881,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c4709881.spcon2)
	e3:SetTarget(c4709881.sptg2)
	e3:SetOperation(c4709881.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡片为怪兽且属于「星遗物」字段（0xfe），用于统计自己墓地的「星遗物」怪兽。
function c4709881.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfe)
end
-- 攻击力上升值计算：获取自己墓地的「星遗物」怪兽，按不同卡名分类计数后乘以300。
function c4709881.atkval(e,c)
	-- 从自己墓地取出所有「星遗物」怪兽，按卡名统计种类数并乘以300，作为攻击力上升数值。
	return Duel.GetMatchingGroup(c4709881.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)*300
end
-- 解放代价的过滤条件：候选卡是「星杯」怪兽、位于这张卡的连接区，且解放后自己场上仍有可用的怪兽区供后续特殊召唤。
function c4709881.cfilter(c,g,tp,zone)
	return c:IsSetCard(0xfd) and g:IsContains(c)
		-- 额外确认：解放该候选怪兽后，自己场上仍有空闲怪兽区可用于后续特殊召唤。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- ②效果的发动代价：从这张卡的连接区选择1只自己的「星杯」怪兽解放，并将其记录到效果标签中，用于后续排除该对象。
function c4709881.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 代价检测：确认场上存在至少1只位于连接区且满足条件的「星杯」怪兽可作为解放代价，同时解放后仍留有空位。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c4709881.cfilter,1,nil,lg,tp,zone) end
	-- 从符合条件的怪兽中选择1只作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c4709881.cfilter,1,1,nil,lg,tp,zone)
	-- 将选择的「星杯」怪兽解放，作为效果发动代价。
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 过滤条件：墓地中的怪兽可以被当前效果特殊召唤（不检查召唤条件与苏生限制）。
function c4709881.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象判定：当指定对象时，要求该对象位于自己墓地、不是被解放的那只怪兽，并且满足特殊召唤条件。
function c4709881.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc~=cc and c4709881.spfilter1(chkc,e,tp) end
	-- 发动条件检测：自己墓地存在除了解放怪兽以外可以特殊召唤的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4709881.spfilter1,tp,LOCATION_GRAVE,0,1,cc,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只除解放怪兽以外满足条件的怪兽作为效果对象，并设为连锁对象。
	local g=Duel.SelectTarget(tp,c4709881.spfilter1,tp,LOCATION_GRAVE,0,1,1,cc,e,tp)
	-- 设置本次效果处理信息：包含特殊召唤效果，处理对象为选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽以表侧表示特殊召唤到这张卡所连接区的自己场上，要求对象仍与效果关联且存在可用的主怪兽区。
function c4709881.spop1(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 获取效果对象（之前选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and zone&0x1f~=0 then
		-- 将对象怪兽以表侧表示特殊召唤到这张卡的连接区（只使用主怪兽区范围）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- ③效果的发动条件：这张卡从场上被送去墓地。
function c4709881.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手卡中的怪兽属于「星杯」字段且可被当前效果特殊召唤。
function c4709881.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动条件检测：自己场上有空余怪兽区，且手卡存在可特殊召唤的「星杯」怪兽。
function c4709881.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的「星杯」怪兽。
		and Duel.IsExistingMatchingCard(c4709881.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果操作信息：从手卡特殊召唤1只「星杯」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：从手卡选择1只「星杯」怪兽，以表侧表示特殊召唤到自己场上。
function c4709881.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时没有空余的怪兽区域，则不再进行后续特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的「星杯」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「星杯」怪兽。
	local g=Duel.SelectMatchingCard(tp,c4709881.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「星杯」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
