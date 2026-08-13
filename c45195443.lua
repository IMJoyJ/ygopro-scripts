--E・HERO ソリッドマン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「英雄」怪兽特殊召唤。
-- ②：这张卡被魔法卡的效果从怪兽区域送去墓地的场合，以「元素英雄 固态侠」以外的自己墓地1只「英雄」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c45195443.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45195443,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45195443.sptg1)
	e1:SetOperation(c45195443.spop1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被魔法卡的效果从怪兽区域送去墓地的场合，以「元素英雄 固态侠」以外的自己墓地1只「英雄」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45195443,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,45195443)
	e2:SetCondition(c45195443.spcon2)
	e2:SetTarget(c45195443.sptg2)
	e2:SetOperation(c45195443.spop2)
	c:RegisterEffect(e2)
end
-- 定义①效果的特殊召唤筛选条件：等级4以下、拥有“英雄”字段、且可以特殊召唤的怪兽。
function c45195443.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：自己主要怪兽区有空位，且手牌中存在至少1只满足spfilter1条件的“英雄”怪兽。
function c45195443.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足spfilter1条件的“英雄”怪兽。
		and Duel.IsExistingMatchingCard(c45195443.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记效果处理信息：从手牌特殊召唤1只怪兽（具体对象在处理时确定），用于其他卡片效果的联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时，先确认仍有空位；展示选择提示后，从手牌中选择1只满足条件的“英雄”怪兽，以表侧表示特殊召唤到自己场上。
function c45195443.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则效果处理不进行，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选满足条件的怪兽，由玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,c45195443.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判定：存在导致移动的效果，且该效果来源是魔法卡；本卡因效果被送去墓地，且之前位于主要怪兽区。
function c45195443.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsType(TYPE_SPELL) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 定义②效果的选择对象筛选条件：位于墓地、拥有“英雄”字段、卡名不是“元素英雄 固态侠”、且可以表侧守备表示特殊召唤的怪兽。
function c45195443.spfilter2(c,e,tp)
	return c:IsSetCard(0x8) and not c:IsCode(45195443) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动时，先检查自己主要怪兽区是否有空位，以及墓地中是否存在满足spfilter2条件的“英雄”怪兽；连锁处理时若为对象确认，则验证对象是否在墓地、属于自己且满足筛选条件。
function c45195443.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45195443.spfilter2(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空余区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只满足spfilter2条件且能成为此效果对象的“英雄”怪兽。
		and Duel.IsExistingTarget(c45195443.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地将满足spfilter2条件的“英雄”怪兽作为对象选择，并设定为效果对象。
	local g=Duel.SelectTarget(tp,c45195443.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记效果处理信息：特殊召唤已确定的对象g（1只），用于其他效果的联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，取得发动时选择的对象；若该对象仍与此效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c45195443.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
