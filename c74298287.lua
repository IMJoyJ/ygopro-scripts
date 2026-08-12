--水精鱗－アビスディーネ
-- 效果：
-- 自己场上有名字带有「水精鳞」的怪兽存在的场合，这张卡用卡的效果从卡组或者墓地加入手卡时，这张卡可以从手卡特殊召唤。此外，这张卡用名字带有「水精鳞」的怪兽的效果特殊召唤成功时，可以从自己墓地选择1只3星以下的名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊蒂妮」的效果1回合只能使用1次。
function c74298287.initial_effect(c)
	-- 自己场上有名字带有「水精鳞」的怪兽存在的场合，这张卡用卡的效果从卡组或者墓地加入手卡时，这张卡可以从手卡特殊召唤。「水精鳞-深渊蒂妮」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74298287,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,74298287)
	e1:SetCondition(c74298287.spcon1)
	e1:SetTarget(c74298287.sptg1)
	e1:SetOperation(c74298287.spop1)
	c:RegisterEffect(e1)
	-- 此外，这张卡用名字带有「水精鳞」的怪兽的效果特殊召唤成功时，可以从自己墓地选择1只3星以下的名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊蒂妮」的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74298287,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,74298287)
	e2:SetCondition(c74298287.spcon2)
	e2:SetTarget(c74298287.sptg2)
	e2:SetOperation(c74298287.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「水精鳞」怪兽
function c74298287.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x74)
end
-- 效果1的发动条件：因卡的效果从卡组或墓地加入手卡，且自己场上有表侧表示的「水精鳞」怪兽存在
function c74298287.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
		-- 检查自己场上是否存在表侧表示的「水精鳞」怪兽
		and Duel.IsExistingMatchingCard(c74298287.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果1的目标：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c74298287.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自身仍存在于手卡且自己场上有可用的怪兽区域
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的处理：再次确认场上存在「水精鳞」怪兽后，将自身特殊召唤
function c74298287.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已没有表侧表示的「水精鳞」怪兽，则不处理
	if not Duel.IsExistingMatchingCard(c74298287.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果2的发动条件：这张卡用名字带有「水精鳞」的怪兽的效果特殊召唤成功时
function c74298287.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x74)
end
-- 过滤条件：自己墓地3星以下的名字带有「水精鳞」的怪兽
function c74298287.spfilter(c,e,tp)
	return c:IsSetCard(0x74) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的目标：选择自己墓地1只符合条件的「水精鳞」怪兽为对象
function c74298287.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74298287.spfilter(chkc,e,tp) end
	-- 在发动检查时，确认自己场上有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只可以特殊召唤的3星以下「水精鳞」怪兽
		and Duel.IsExistingTarget(c74298287.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「水精鳞」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74298287.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤该目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果2的处理：将选择的墓地怪兽特殊召唤
function c74298287.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
