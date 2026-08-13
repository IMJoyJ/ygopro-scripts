--ドラゴンメイド・ナサリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以除「半龙女仆·育婴龙女」外的自己墓地1只4星以下的「半龙女仆」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
function c40398073.initial_effect(c)
	-- 对应①效果的发动与处理：①：这张卡召唤·特殊召唤的场合，以除「半龙女仆·育婴龙女」外的自己墓地1只4星以下的「半龙女仆」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40398073,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,40398073)
	e1:SetTarget(c40398073.sptg1)
	e1:SetOperation(c40398073.spop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对应②效果：②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40398073,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40398074)
	e3:SetTarget(c40398073.sptg2)
	e3:SetOperation(c40398073.spop2)
	c:RegisterEffect(e3)
end
-- 过滤墓地中可作为①对象的怪兽：需为「半龙女仆」字段、4星以下、卡名不是「半龙女仆·育婴龙女」，且能被特殊召唤。
function c40398073.spfilter1(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelBelow(4) and not c:IsCode(40398073) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与取对象目标检查：chkc时验证目标位于自己墓地且满足spfilter1；chk==0时需场上有空位且墓地存在至少1只满足条件的对象。
function c40398073.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40398073.spfilter1(chkc,e,tp) end
	-- 发动条件之一：自己场上存在可用的怪兽区（用于特殊召唤目标怪兽）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足spfilter1且可成为效果对象的「半龙女仆」怪兽。
		and Duel.IsExistingTarget(c40398073.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡（供后续选择目标的UI显示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter1的「半龙女仆」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c40398073.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：此连锁将进行1只怪兽的特殊召唤，对象为已选定的目标，供其他卡发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象并检查关联，若对象仍有效则将其特殊召唤。
function c40398073.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象，即被选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上（不无视召唤条件/苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡·墓地中可作为②特殊召唤对象的怪兽：需为「半龙女仆」字段、7星且可被特殊召唤。
function c40398073.spfilter2(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：本卡能回手牌、本卡离开后自己仍有可用怪兽区、且手卡·墓地存在至少1只满足spfilter2的「半龙女仆」怪兽。
function c40398073.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 发动条件之一：本卡回到手牌后，自己场上仍有可用的怪兽区（用于特殊召唤7星怪兽）。
		and Duel.GetMZoneCount(tp,c)>0
		-- 发动条件之二：自己的手卡·墓地存在至少1只满足spfilter2的7星「半龙女仆」怪兽（不取对象，处理时选择）。
		and Duel.IsExistingMatchingCard(c40398073.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁处理中包含将本卡回到手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：本连锁预定从手卡·墓地特殊召唤1只怪兽（目标处理时选择，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：本卡回手牌，成功且确认在手牌、场上仍有空位时，从手卡·墓地选择1只7星「半龙女仆」怪兽特殊召唤。
function c40398073.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理条件：本卡仍与效果关联，且将其送回手牌成功（返回值不为0）。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 继续处理条件：本卡确实在手牌，且自己场上有可用的怪兽区。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示：请选择要特殊召唤的卡（供后续选择目标的UI显示）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·墓地选择1只满足spfilter2且不受王家长眠之谷影响的7星「半龙女仆」怪兽（不取对象，处理时选择）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c40398073.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的7星「半龙女仆」怪兽以表侧表示特殊召唤到自己场上（不无视召唤条件/苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
