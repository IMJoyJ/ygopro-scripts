--魔界台本「ドラマチック・ストーリー」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。和那只怪兽卡名不同的1只「魔界剧团」怪兽从卡组特殊召唤。那之后，作为对象的怪兽在自己的灵摆区域放置或破坏。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。选场上最多2张卡回到持有者手卡。
function c33503878.initial_effect(c)
	-- ①：以自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。和那只怪兽卡名不同的1只「魔界剧团」怪兽从卡组特殊召唤。那之后，作为对象的怪兽在自己的灵摆区域放置或破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33503878,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,33503878+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c33503878.target)
	e1:SetOperation(c33503878.operation)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。选场上最多2张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33503878,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c33503878.thcon)
	e2:SetTarget(c33503878.thtg)
	e2:SetOperation(c33503878.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否满足条件：表侧表示、魔界剧团族、灵摆类型，并且卡组中存在与该怪兽不同名的魔界剧团怪兽可以特殊召唤。
function c33503878.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM)
		-- 检查卡组中是否存在满足条件的魔界剧团怪兽（与目标怪兽不同名），用于确认是否可以发动效果。
		and Duel.IsExistingMatchingCard(c33503878.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 特殊召唤过滤函数，用于筛选卡组中满足条件的魔界剧团怪兽（不同名、可特殊召唤）。
function c33503878.spfilter(c,e,tp,code)
	return c:IsSetCard(0x10ec) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数，用于判断是否可以发动效果：场上存在满足条件的魔界剧团灵摆怪兽作为对象。
function c33503878.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c33503878.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的魔界剧团灵摆怪兽作为对象。
		and Duel.IsExistingTarget(c33503878.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的魔界剧团灵摆怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的魔界剧团灵摆怪兽作为对象。
	local g=Duel.SelectTarget(tp,c33503878.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤一张魔界剧团怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行效果的主要逻辑：特殊召唤怪兽并选择放置或破坏对象怪兽。
function c33503878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 提示玩家选择要特殊召唤的魔界剧团怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的魔界剧团怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c33503878.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 检查玩家的灵摆区域是否有空位，并判断目标怪兽是否被禁止放置。
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not tc:IsForbidden()
			-- 选择将目标怪兽放置于灵摆区域或破坏。
			and Duel.SelectOption(tp,aux.Stringid(33503878,2),aux.Stringid(33503878,3))==0 then  --"在灵摆区域放置/破坏"
			-- 中断当前效果处理流程，使后续处理视为独立时点。
			Duel.BreakEffect()
			-- 将目标怪兽移动到玩家的灵摆区域。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 中断当前效果处理流程，使后续处理视为独立时点。
			Duel.BreakEffect()
			-- 破坏目标怪兽。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断额外卡组中是否存在满足条件的魔界剧团灵摆怪兽。
function c33503878.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
end
-- 破坏时触发效果的条件函数，判断该卡是否因对方效果被破坏且满足发动条件。
function c33503878.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查额外卡组中是否存在满足条件的魔界剧团灵摆怪兽。
		and Duel.IsExistingMatchingCard(c33503878.cfilter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 设置效果处理信息，表示将要将场上卡返回手牌。
function c33503878.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一张可返回手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取所有可返回手牌的场上卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将要将卡返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行效果的主要逻辑：选择最多2张卡返回手牌。
function c33503878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上最多2张可返回手牌的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 将选中的卡送回持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
