--天威龍－シュターナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：效果怪兽以外的自己场上的表侧表示怪兽被战斗·效果破坏的场合，把手卡·墓地的这张卡除外，以那1只破坏的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以选对方场上1只怪兽破坏。
function c24557335.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24557335,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,24557335)
	e1:SetCondition(c24557335.spcon)
	e1:SetTarget(c24557335.sptg)
	e1:SetOperation(c24557335.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：效果怪兽以外的自己场上的表侧表示怪兽被战斗·效果破坏的场合，把手卡·墓地的这张卡除外，以那1只破坏的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以选对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24557335,1))  --"特殊召唤破坏的怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,24557336)
	e2:SetCondition(c24557335.descon)
	-- 设置②效果的发动代价：把手卡·墓地的这张卡除外才能发动；aux.bfgcost会检查这张卡能否除外，并以其当前所在位置将这张卡除外作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24557335.destg)
	e2:SetOperation(c24557335.desop)
	c:RegisterEffect(e2)
end
-- 定义spcfilter过滤条件：判断卡片是否为效果怪兽（TYPE_EFFECT）且表侧表示，用于检查场上是否存在效果怪兽。
function c24557335.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 定义①效果的发动条件spcon：自己场上不存在表侧表示的效果怪兽时满足（通过检索自己主要怪兽区，若找不到1张符合条件的卡则条件成立）。
function c24557335.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 用Duel.IsExistingMatchingCard检查自己场上是否存在至少1张表侧表示的效果怪兽，并取反；不存在时返回true，即满足①的发动条件。
	return not Duel.IsExistingMatchingCard(c24557335.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义①效果的目标处理sptg：在发动时先确认自己场上有可用怪兽区，且这张卡自身能够被特殊召唤；满足时后续效果处理中执行特殊召唤。
function c24557335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：我方场上主要怪兽区有空余位置（Duel.GetLocationCount>0），才能把这张卡从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将本次效果处理设为“特殊召唤这张卡”，数量为1，供系统处理特殊召唤相关的后续判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果处理spop：取得这张卡，若它仍与这个效果关联（未被离场等原因解除联系），则将其从手卡特殊召唤到自己场上。
function c24557335.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：把这张卡以表侧表示特殊召唤到发动者tp的场上；nocheck=false/nolimit=false表示仍需检查特殊召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义被破坏怪兽的过滤条件descfilter：该怪兽的破坏原因为战斗或效果，破坏前在场上是非效果怪兽，且位于我方主要怪兽区、表侧表示、控制者为我方。
function c24557335.descfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousTypeOnField(),TYPE_EFFECT)==0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：本次被破坏的怪兽组eg中存在至少1只满足descfilter的怪兽，即我方场上的非效果表侧怪兽被战斗/效果破坏。
function c24557335.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24557335.descfilter,1,nil,tp)
end
-- 定义②效果对象候选过滤tgfilter：该怪兽必须是本次被破坏的怪兽中满足非效果、我方表侧、战破/效破条件的，当前位于墓地或除外区，能够成为效果对象且能够被特殊召唤。
function c24557335.tgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c24557335.descfilter(c,tp)
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 定义②效果的目标处理destg：从本次被破坏的怪兽中筛选可特殊召唤的候选组；若满足发动条件（有怪兽区且有候选），则选择其中1只作为对象；若只有1只则直接选用；最后将所选怪兽设为效果对象并登记特殊召唤操作信息。
function c24557335.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c24557335.tgfilter,nil,e,tp)
	if chkc then return eg:IsContains(chkc) and c24557335.tgfilter(chkc,e,tp) end
	-- ②发动条件检查：我方场上主要怪兽区有空位，且存在至少1只符合条件的被破坏怪兽（g:GetCount()>0），否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	local c=nil
	if g:GetCount()>1 then
		-- 显示选择提示“请选择要特殊召唤的卡”，将玩家的选择缓存用于后续选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	-- 把选择出的怪兽设置为当前连锁的效果对象（取对象），使该卡与这个效果建立联系，并供后续GetFirstTarget获取。
	Duel.SetTargetCard(c)
	-- 登记操作信息：将本次效果处理登记为“特殊召唤c”，数量为1，供系统进行特殊召唤相关时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义②效果处理desop：取得对象怪兽，若仍与效果关联则将其特殊召唤；召唤成功后若对方场上有怪兽，则询问玩家是否破坏对方1只怪兽；选择是则选择1只对方怪兽，中断效果后将其破坏。
function c24557335.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得②效果发动时选择的对象怪兽，即被指定要特殊召唤的那只被破坏的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将对象怪兽以表侧表示特殊召唤到tp的场上，并判断是否特殊召唤成功（返回值>0），只有成功后才进行后续的破坏选择。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查对方场上（以tp为参照的另一方）主要怪兽区是否存在怪兽，若存在才能选择破坏对方怪兽。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 弹出“是否破坏对方怪兽？”的确认选择，只有玩家选择“是”时才执行后续的选怪与破坏处理，对应“那之后，可以选对方场上1只怪兽破坏”的可选部分。
		and Duel.SelectYesNo(tp,aux.Stringid(24557335,2)) then  --"是否破坏对方怪兽？"
		-- 显示选择提示“请选择要破坏的卡”，为接下来选择对方场上要破坏的怪兽做准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从对方场上的主要怪兽区选择1只怪兽（不取对象，在效果处理时选择），存入g供后续破坏。
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 调用BreakEffect中断当前效果，使后续的破坏处理与前面的特殊召唤不视为同时处理，造成错时点。
			Duel.BreakEffect()
			-- Duel.HintSelection手动为选中的怪兽显示被选为对象的动画，并记录这些卡为广义上的对象（用于相关判定）。
			Duel.HintSelection(g)
			-- 以“效果”这一原因（REASON_EFFECT）破坏选择的那只对方怪兽，完成②效果的后续可选破坏处理。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
