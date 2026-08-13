--古代の機械素体
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。把1只「古代的机械巨人」或者1张有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从手卡把「古代的机械巨人」「古代的机械巨人-究极重击」合计最多3只无视召唤条件特殊召唤。
function c1278431.initial_effect(c)
	-- aux.AddCodeList(c,83104731) 是脚本的自定义API，给这张卡注册一个“代码列表”，标记其效果文本中记述了「古代的机械巨人」(83104731)，从而让 aux.IsCodeListed 能用来判断其他卡是否记载了这个卡名。
	aux.AddCodeList(c,83104731)
	-- 这个卡名的①的效果1回合只能使用1次。①：丢弃1张手卡才能发动。把1只「古代的机械巨人」或者1张有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1278431,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,1278431)
	e1:SetCost(c1278431.thcost)
	e1:SetTarget(c1278431.thtg)
	e1:SetOperation(c1278431.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c1278431.aclimit)
	e2:SetCondition(c1278431.actcon)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从手卡把「古代的机械巨人」「古代的机械巨人-究极重击」合计最多3只无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1278431,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c1278431.spcon)
	e3:SetTarget(c1278431.sptg)
	e3:SetOperation(c1278431.spop)
	c:RegisterEffect(e3)
end
-- 代价函数：从手卡丢弃1张卡作为发动代价。先通过chk阶段检查是否有可丢弃的手卡，再在执行阶段丢弃1张手卡，丢弃原因设为代价并丢弃。
function c1278431.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：手牌中存在至少1张可以被丢弃的卡（Card.IsDiscardable）时才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：己方从手卡选择1张可丢弃的卡丢弃，丢弃原因同时标记为REASON_COST（代价）和REASON_DISCARD（丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数：用于筛选“古代的机械巨人”卡，或卡名中记述了「古代的机械巨人」的魔法·陷阱卡，且该卡能够加入手卡。
function c1278431.thfilter(c)
	-- 过滤条件具体为：卡号为83104731（即「古代的机械巨人」），或者具有魔法/陷阱类型且其效果文本中记述了83104731，并且该卡当前可以被加入手卡。
	return (c:IsCode(83104731) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,83104731))) and c:IsAbleToHand()
end
-- 目标函数：发动时确认卡组存在符合条件的检索目标，并设置操作信息为从卡组检索加入手卡。
function c1278431.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张满足thfilter过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1278431.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理涉及从卡组把1张卡加入手卡（CATEGORY_TOHAND），供星尘龙等卡进行效果发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择1张符合条件的卡加入手卡，并让对手确认。
function c1278431.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出系统提示“请选择要加入手牌的卡”，用于后续选择卡牌时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中筛选并选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c1278431.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入其持有者的手卡（nil表示持有者），处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把检索加入手卡的卡展示给对方玩家确认，以验证检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- aclimit 作为EFFECT_CANNOT_ACTIVATE的Value函数：判断对方试图发动的效果是否为魔法·陷阱卡的发动（即EFFECT_TYPE_ACTIVATE）。
function c1278431.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- actcon 条件函数：用于判定“这张卡攻击的场合”，即当前攻击宣言的怪兽正是本卡。
function c1278431.actcon(e)
	-- 返回当前攻击怪兽是否为这张卡本身，只有本卡攻击时才会禁止对方发动魔陷。
	return Duel.GetAttacker()==e:GetHandler()
end
-- spcon 离场诱发条件：这张卡在场上表侧表示时，因对方发动的效果而离场的场合，满足发动条件。
function c1278431.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- spfilter 过滤函数：手牌中的「古代的机械巨人」(83104731)或「古代的机械巨人-究极重击」(95735217)且可以无视召唤条件进行特殊召唤的怪兽。
function c1278431.spfilter(c,e,tp)
	return c:IsCode(83104731,95735217) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 目标函数：发动③效果时，检查己方怪兽区有空位且手牌存在至少1只符合条件的可特殊召唤怪兽。
function c1278431.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡中是否存在至少1只满足spfilter的怪兽（传入额外的e和tp参数）。
		and Duel.IsExistingMatchingCard(c1278431.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从手卡进行特殊召唤（CATEGORY_SPECIAL_SUMMON），用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理函数：根据可用的怪兽区空格数决定特殊召唤数量（通常最多3只），并受「青眼精灵龙」限制时最多1只，然后从手牌选择并特殊召唤。
function c1278431.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算实际可特殊召唤的数量：取怪兽区可用空格数与3的较小值，作为最多可选择数。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	if ft<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1到ft张符合spfilter条件的怪兽（ft为之前计算的可特殊召唤数量）。
	local g=Duel.SelectMatchingCard(tp,c1278431.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件、以表侧攻击表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
