--天威龍－シュターナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：效果怪兽以外的自己场上的表侧表示怪兽被战斗·效果破坏的场合，把手卡·墓地的这张卡除外，以那1只破坏的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以选对方场上1只怪兽破坏。
function c24557335.initial_effect(c)
	-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：效果怪兽以外的自己场上的表侧表示怪兽被战斗·效果破坏的场合，把手卡·墓地的这张卡除外，以那1只破坏的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以选对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24557335,1))  --"特殊召唤破坏的怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,24557336)
	e2:SetCondition(c24557335.descon)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24557335.destg)
	e2:SetOperation(c24557335.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在表侧表示的效果怪兽
function c24557335.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果①的发动条件，判断自己场上是否没有效果怪兽
function c24557335.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有效果怪兽
	return not Duel.IsExistingMatchingCard(c24557335.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时的处理，判断是否满足特殊召唤的条件
function c24557335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理，将这张卡特殊召唤
function c24557335.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断被破坏的怪兽是否满足效果②的条件
function c24557335.descfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousTypeOnField(),TYPE_EFFECT)==0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp)
end
-- 效果②的发动条件，判断是否有满足条件的怪兽被破坏
function c24557335.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24557335.descfilter,1,nil,tp)
end
-- 过滤函数，用于判断被破坏的怪兽是否满足特殊召唤的条件
function c24557335.tgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c24557335.descfilter(c,tp)
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的发动时的处理，选择要特殊召唤的怪兽
function c24557335.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c24557335.tgfilter,nil,e,tp)
	if chkc then return eg:IsContains(chkc) and c24557335.tgfilter(chkc,e,tp) end
	-- 判断自己场上是否有空位且有满足条件的怪兽可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	local c=nil
	if g:GetCount()>1 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	-- 设置当前效果的目标怪兽
	Duel.SetTargetCard(c)
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的发动处理，将被破坏的怪兽特殊召唤并可破坏对方怪兽
function c24557335.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将目标怪兽特殊召唤到场上
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 判断对方场上是否有怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 询问玩家是否要破坏对方怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(24557335,2)) then  --"是否破坏对方怪兽？"
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1只怪兽作为破坏对象
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 显示被选为对象的怪兽
			Duel.HintSelection(g)
			-- 将选中的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
