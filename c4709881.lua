--星杯剣士アウラム
-- 效果：
-- 「星杯」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升自己墓地的「星遗物」怪兽种类×300。
-- ②：把这张卡所连接区1只自己的「星杯」怪兽解放，以那只怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c4709881.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只以上满足过滤条件的「星杯」怪兽作为连接素材
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
	-- ②：把这张卡所连接区1只自己的「星杯」怪兽解放，以那只怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
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
-- 过滤满足条件的「星遗物」怪兽（类型为怪兽且种族为0xfe）
function c4709881.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfe)
end
-- 计算自己墓地中「星遗物」怪兽数量并乘以300作为攻击力加成
function c4709881.atkval(e,c)
	-- 获取自己墓地中满足条件的怪兽数量（按卡号分类），再乘以300作为攻击力加成
	return Duel.GetMatchingGroup(c4709881.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)*300
end
-- 过滤满足条件的「星杯」怪兽，要求其在连接区中且场上存在可用区域
function c4709881.cfilter(c,g,tp,zone)
	return c:IsSetCard(0xfd) and g:IsContains(c)
		-- 检查目标怪兽所在位置是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置效果发动时的解放费用，选择一只满足条件的连接怪兽进行解放
function c4709881.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检测是否可以支付解放费用（即是否存在满足条件的连接怪兽）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c4709881.cfilter,1,nil,lg,tp,zone) end
	-- 从场上选择一只满足条件的连接怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c4709881.cfilter,1,1,nil,lg,tp,zone)
	-- 实际执行解放操作，将选中的怪兽从场上解放作为效果发动的代价
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 过滤满足特殊召唤条件的怪兽（不取对象）
function c4709881.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，限定目标为墓地中的怪兽且不能是已解放的怪兽
function c4709881.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc~=cc and c4709881.spfilter1(chkc,e,tp) end
	-- 检测是否可以发动此效果（即是否存在满足条件的墓地怪兽）
	if chk==0 then return Duel.IsExistingTarget(c4709881.spfilter1,tp,LOCATION_GRAVE,0,1,cc,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择一只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c4709881.spfilter1,tp,LOCATION_GRAVE,0,1,1,cc,e,tp)
	-- 设置操作信息，表示将特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理，将选中的怪兽特殊召唤到场上
function c4709881.spop1(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 获取当前连锁中指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and zone&0x1f~=0 then
		-- 将目标怪兽以指定方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 判断此效果是否可以发动（即该卡是从场上送去墓地的）
function c4709881.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足特殊召唤条件的「星杯」怪兽（不取对象）
function c4709881.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，检测手牌中是否存在满足条件的怪兽
function c4709881.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c4709881.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从手牌特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果处理，从手牌选择一只「星杯」怪兽并特殊召唤到场上
function c4709881.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一只满足条件的怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c4709881.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以指定方式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
