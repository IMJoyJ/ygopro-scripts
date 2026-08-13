--千年の眠りから覚めし原人
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1只「千年」怪兽加入手卡。
-- ③：这张卡只要在怪兽区域存在，不会被怪兽的效果破坏。
local s,id,o=GetID()
-- 定义该卡初始化函数：注册①手卡当作永续魔法放置、②当作永续魔法时特招并检索「千年」怪兽、③不被怪兽效果破坏三个效果，并预先登记卡名「千年十字」。
function s.initial_effect(c)
	-- 登记这张卡上记载的卡名「千年十字」（卡号37613663），用于规则上视为记载有该卡名。
	aux.AddCodeList(c,37613663)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作魔法卡放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1只「千年」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡只要在怪兽区域存在，不会被怪兽的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
-- ①效果发动时的合法性检测：确认自己的魔法与陷阱区域是否存在空位可供放置。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查己方魔陷区是否有空位，有才可发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ①效果处理：将这张卡从手卡移动到自己魔陷区表侧表示放置，并赋予其“永续魔法卡”的卡片种类。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以表侧表示移动到自己的魔法与陷阱区域，若移动成功则继续后续改变种类的处理。
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：这张卡在魔陷区且当前种类为“永续魔法”（即当作永续魔法卡使用）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 过滤器：手卡中的「千年十字」（卡号37613663）且未向对方公开的卡。
function s.cfilter1(c,tp)
	return c:IsCode(37613663) and not c:IsPublic()
end
-- ②效果的代价处理：在“支付2000基本分”和“向对方展示手卡1张「千年十字」”中选择一项；若两项均满足则由玩家选择，否则支付其中可行的一项。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测手卡是否存在满足条件的「千年十字」作为展示代价。
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检测自己是否能够支付2000基本分作为代价。
	local b2=Duel.CheckLPCost(tp,2000)
	if chk==0 then return b1 or b2 end
	-- 当两种代价都可行时，询问玩家是否选择展示「千年十字」，是则走展示分支，否则若可支付LP则支付LP。
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否出示「千年十字」？"
		-- 发出“选择要展示给对方确认的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手卡选择1张符合过滤器s.cfilter1的「千年十字」卡。
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的「千年十字」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切手卡（因手卡信息已变化，需重置手卡顺序）。
		Duel.ShuffleHand(tp)
	elseif b2 then
		-- 支付2000基本分作为发动代价。
		Duel.PayLPCost(tp,2000)
	else
		-- 发出“选择要展示给对方确认的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手卡选择1张「千年十字」用于展示。
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的「千年十字」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切手卡，避免手牌顺序信息泄露。
		Duel.ShuffleHand(tp)
	end
end
-- ②效果的目标判定与操作信息设置：确认主怪兽区有空位且自己能以表侧表示特殊召唤这张卡，并登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查主怪兽区空位，并确认该卡可以被自身效果特殊召唤（数值/种族/属性/等级设定，作为效果怪兽特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,2750,2500,8,RACE_BEASTWARRIOR,ATTRIBUTE_EARTH) end
	-- 向连锁系统登记本次效果包含“特殊召唤1只怪兽”的操作信息（对象为本卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 检索过滤器：卡组中属于「千年」字段、是怪兽卡且可以加入手卡的卡。
function s.filter(c)
	return c:IsSetCard(0x1ae) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果处理：先特殊召唤这张卡；成功后询问玩家是否从卡组检索「千年」怪兽，若选择是则选1张加入手卡并向对方展示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联且特殊召唤成功，且卡组中存在符合条件的「千年」怪兽，并征得玩家同意后才执行检索。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把「千年」怪兽加入手卡？"
		-- 发出“选择要加入手卡的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足s.filter的「千年」怪兽卡。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前连锁的效果处理，使后续加入手卡的处理作为独立时点，避免与之前特殊召唤同时处理而错失时点。
			Duel.BreakEffect()
			-- 将选中的「千年」怪兽卡加入持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将检索加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ③效果的判定函数：当引发破坏的效果是怪兽效果时返回true，从而使此卡不会被这类效果破坏。
function s.efilter(e,re)
	return re:IsActiveType(TYPE_EFFECT)
end
