--幻想魔術師・ノー・フェイス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的表侧表示的「眼纳祭神」融合怪兽或者「纳祭之魔」被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以自己墓地1只「眼纳祭神」融合怪兽或者「纳祭之魔」为对象才能发动。那只怪兽特殊召唤。
function c15173384.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上的表侧表示的「眼纳祭神」融合怪兽或者「纳祭之魔」被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,15173384)
	e1:SetCondition(c15173384.spcon1)
	e1:SetTarget(c15173384.sptg1)
	e1:SetOperation(c15173384.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以自己墓地1只「眼纳祭神」融合怪兽或者「纳祭之魔」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,15173385)
	e2:SetCondition(c15173384.spcon2)
	e2:SetTarget(c15173384.sptg2)
	e2:SetOperation(c15173384.spop2)
	c:RegisterEffect(e2)
end
-- 用于判断被破坏的怪兽是否为「眼纳祭神」融合怪兽或「纳祭之魔」，并且是战斗或效果破坏，且在自己场上正面表示被破坏。
function c15173384.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and ((c:IsPreviousSetCard(0x1110) and bit.band(c:GetPreviousTypeOnField(),TYPE_FUSION)~=0) or c:GetPreviousCodeOnField()==64631466)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否有满足条件的怪兽被破坏，即是否触发效果①。
function c15173384.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15173384.cfilter,1,nil,tp)
end
-- 判断是否可以发动效果①，即场上是否有空位且该卡可以特殊召唤。
function c15173384.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理函数，将此卡特殊召唤到场上。
function c15173384.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否从场上送去墓地，即是否触发效果②。
function c15173384.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 用于筛选墓地中的「眼纳祭神」融合怪兽或「纳祭之魔」，确保其可以被特殊召唤。
function c15173384.filter(c,e,tp)
	return ((c:IsSetCard(0x1110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果②，即场上是否有空位且墓地中有符合条件的怪兽。
function c15173384.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15173384.filter(chkc,e,tp) end
	-- 判断场上是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c15173384.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择墓地中符合条件的怪兽作为效果②的目标。
	local g=Duel.SelectTarget(tp,c15173384.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果②的处理信息，表示将特殊召唤所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理函数，将目标怪兽特殊召唤到场上。
function c15173384.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
