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
-- 判断被破坏的怪兽是否满足①效果条件：是被战斗·效果破坏，且破坏前为己方场上主要怪兽区表侧表示的「眼纳祭神」融合怪兽或「纳祭之魔」。
function c15173384.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and ((c:IsPreviousSetCard(0x1110) and bit.band(c:GetPreviousTypeOnField(),TYPE_FUSION)~=0) or c:GetPreviousCodeOnField()==64631466)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ①效果触发条件：被破坏的怪兽集合中存在至少1只满足cfilter条件的卡，即己方场上的表侧表示「眼纳祭神」融合怪兽或「纳祭之魔」被战斗·效果破坏。
function c15173384.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15173384.cfilter,1,nil,tp)
end
-- ①效果发动的合法性确认：检查自己主要怪兽区有空位，且这张卡自身可以被特殊召唤，满足时才允许发动。
function c15173384.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：将特殊召唤这张卡登记为CATEGORY_SPECIAL_SUMMON，用于时点检测等后续判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：获取效果持有者（这张卡），若这张卡仍与本次效果关联，则将其特殊召唤。
function c15173384.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将无脸幻想魔术师以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果触发条件：这张卡从场上被送去墓地，而不是从手牌·卡组直接送入墓地。
function c15173384.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 目标怪兽的筛选条件：自己墓地中存在「眼纳祭神」融合怪兽（系列0x1110且类型为融合）或「纳祭之魔」（卡号64631466），且可以被特殊召唤。
function c15173384.filter(c,e,tp)
	return ((c:IsSetCard(0x1110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动的合法性确认：若指定对象则验证该对象是自己墓地且满足filter；否则检查主要怪兽区有空位且墓地存在合法对象。
function c15173384.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15173384.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地存在至少1只满足filter条件且可被选择为对象的「眼纳祭神」融合怪兽或「纳祭之魔」。
		and Duel.IsExistingTarget(c15173384.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足filter条件的怪兽作为效果对象，并将该对象绑定到当前连锁。
	local g=Duel.SelectTarget(tp,c15173384.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：对选择的对象进行特殊召唤，登记为CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：获取对象怪兽，若对象仍与本次效果关联，则将其特殊召唤。
function c15173384.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 执行特殊召唤：将目标怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
