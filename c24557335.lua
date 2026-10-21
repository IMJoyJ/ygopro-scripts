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
	-- 发动Cost：把手卡·墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c24557335.destg)
	e2:SetOperation(c24557335.desop)
	c:RegisterEffect(e2)
end
-- 场上表侧表示效果怪兽的过滤条件
function c24557335.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上没有效果怪兽存在
function c24557335.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的效果怪兽
	return not Duel.IsExistingMatchingCard(c24557335.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动目标及合法性检测
function c24557335.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身表侧表示特殊召唤
function c24557335.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 特殊召唤自身上场
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 被破坏怪兽的过滤条件：自己场上表侧表示的效果怪兽以外的怪兽因战斗或效果被破坏
function c24557335.descfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and bit.band(c:GetPreviousTypeOnField(),TYPE_EFFECT)==0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp)
end
-- 效果②的发动条件：存在满足条件的被破坏怪兽
function c24557335.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24557335.descfilter,1,nil,tp)
end
-- 作为对象的被破坏怪兽过滤条件：在墓地或除外区且能被特殊召唤
function c24557335.tgfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c24557335.descfilter(c,tp)
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的发动目标选择及合法性检测
function c24557335.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c24557335.tgfilter,nil,e,tp)
	if chkc then return eg:IsContains(chkc) and c24557335.tgfilter(chkc,e,tp) end
	-- 检查怪兽区域是否有可用空格且存在合法的被破坏怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 end
	local c=nil
	if g:GetCount()>1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	-- 将选择的破坏怪兽设为效果对象
	Duel.SetTargetCard(c)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理：特殊召唤目标怪兽，并可选破坏对方场上1只怪兽
function c24557335.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象的被破坏怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将目标怪兽表侧表示特殊召唤
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 询问玩家是否选择破坏对方场上的怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(24557335,2)) then  --"是否破坏对方怪兽？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1只怪兽
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示选中的怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			-- 破坏选中的对方怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
