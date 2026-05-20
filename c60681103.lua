--巨神竜フェルグラント
-- 效果：
-- ①：这张卡从墓地的特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外，这张卡的攻击力·守备力上升除外的那只怪兽的等级或者阶级×100。
-- ②：这张卡战斗破坏对方怪兽的场合，以「巨神龙 闪耀」以外的自己或者对方的墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c60681103.initial_effect(c)
	-- ①：这张卡从墓地的特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外，这张卡的攻击力·守备力上升除外的那只怪兽的等级或者阶级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c60681103.rmcon)
	e1:SetTarget(c60681103.rmtg)
	e1:SetOperation(c60681103.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的场合，以「巨神龙 闪耀」以外的自己或者对方的墓地1只7·8星的龙族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动的条件为：自身与对方怪兽进行战斗并将其破坏。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c60681103.sptg)
	e2:SetOperation(c60681103.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：检测这张卡是否是从墓地特殊召唤成功。
function c60681103.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 效果①的过滤条件：对方场上或墓地的怪兽卡，且可以被除外。
function c60681103.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果①的发动准备（Target）：检查是否存在可除外的目标，并选择该目标，设置操作信息。
function c60681103.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c60681103.rmfilter(chkc) end
	-- 效果发动时的可行性检查：对方场上或墓地是否存在至少1只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c60681103.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从对方场上（其次从墓地）选择1只怪兽作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,c60681103.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		-- 若目标在墓地，设置连锁处理的操作信息为：除外对方墓地的1张卡。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 若目标在场上，设置连锁处理的操作信息为：除外该卡。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 效果①的执行效果（Operation）：将选中的怪兽除外，并根据其等级或阶级上升这张卡的攻击力和守备力。
function c60681103.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的唯一对象。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local atk=0
	-- 确认对象卡片仍符合效果，并将其表侧表示除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		if tc:IsType(TYPE_XYZ) then atk=tc:GetRank() else atk=tc:GetLevel() end
		if c:IsFaceup() and c:IsRelateToEffect(e) and atk>0 then
			-- 这张卡的攻击力·守备力上升除外的那只怪兽的等级或者阶级×100。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e2)
		end
	end
end
-- 效果②的过滤条件：自己或对方墓地中「巨神龙 闪耀」以外的7·8星龙族怪兽，且可以被特殊召唤。
function c60681103.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7,8) and not c:IsCode(60681103)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）：检查自身怪兽区域是否有空位、墓地是否有符合条件的目标，并选择该目标，设置特殊召唤的操作信息。
function c60681103.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c60681103.filter(chkc,e,tp) end
	-- 效果发动时的可行性检查：检查自己场上是否有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时的可行性检查：检查双方墓地是否存在至少1只符合条件的龙族怪兽。
		and Duel.IsExistingTarget(c60681103.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地中1只符合条件的龙族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c60681103.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息为：特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的执行效果（Operation）：将选中的墓地怪兽在自己场上特殊召唤。
function c60681103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的特殊召唤对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
