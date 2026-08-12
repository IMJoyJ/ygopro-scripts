--憑依連携
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·墓地把1只守备力1500的魔法师族怪兽表侧攻击表示或里侧守备表示特殊召唤。那之后，自己场上的怪兽的属性是2种类以上的场合，可以把场上1张表侧表示卡破坏。
-- ②：把墓地的这张卡除外，以自己墓地1张「凭依」永续魔法·永续陷阱卡为对象才能发动。那张卡在自己场上表侧表示放置。
function c65046521.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只守备力1500的魔法师族怪兽表侧攻击表示或里侧守备表示特殊召唤。那之后，自己场上的怪兽的属性是2种类以上的场合，可以把场上1张表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65046521,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,65046521)
	e1:SetTarget(c65046521.target)
	e1:SetOperation(c65046521.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「凭依」永续魔法·永续陷阱卡为对象才能发动。那张卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65046521,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,65046521)
	-- 将墓地的这张卡除外作为发动效果的cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c65046521.tftg)
	e2:SetOperation(c65046521.tfop)
	c:RegisterEffect(e2)
end
-- 过滤条件：守备力1500且可以表侧攻击表示或里侧守备表示特殊召唤的魔法师族怪兽
function c65046521.filter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- ①号效果的发动准备与合法性检测
function c65046521.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c65046521.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①号效果的处理逻辑
function c65046521.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则无法特殊召唤，直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c65046521.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧攻击表示或里侧守备表示特殊召唤，若是里侧表示则给对方确认
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
	end
	-- 获取自己场上所有表侧表示的怪兽
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 获取场上除这张卡以外的所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 若自己场上怪兽的属性在2种类以上，且场上有可破坏的表侧表示卡，玩家可以选择是否发动破坏效果
	if aux.GetAttributeCount(mg)>=2 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(65046521,1)) then  --"是否选1张卡破坏？"
		-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择场上1张除这张卡以外的表侧表示卡
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 选中卡片并向双方玩家展示
			Duel.HintSelection(g)
			-- 破坏选中的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己墓地的「凭依」永续魔法·永续陷阱卡，且不能是被禁止放置的卡
function c65046521.tffilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xc0) and not c:IsForbidden()
end
-- ②号效果的发动准备、对象选择与合法性检测
function c65046521.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c65046521.tffilter(chkc) and chkc:IsControler(tp) end
	-- 检查自己场上是否有空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1张满足条件的「凭依」永续魔法·永续陷阱卡
		and Duel.IsExistingTarget(c65046521.tffilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家选择墓地中1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c65046521.tffilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示有1张卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②号效果的处理逻辑
function c65046521.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否已满，若满则无法放置，直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡在自己的魔法与陷阱区域表侧表示放置
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
