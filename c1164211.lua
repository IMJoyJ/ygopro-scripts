--千年王朝の盾
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「千年十字」加入手卡。
-- ③：这张卡只要在怪兽区域存在，不会被魔法·陷阱卡的效果破坏。
local s,id,o=GetID()
-- 注册这张卡在游戏内的3个效果：①在手牌作为起动效果，将自己放到魔陷区并当作永续魔法；②在魔陷区作为永续魔法时，以出示手牌「千年十字」或支付2000LP为代价特殊召唤自己，并可检索「千年十字」；③在怪兽区拥有不被魔法·陷阱卡效果破坏的抗性；同时为①②设置同名卡1回合各1次的发动限制。
function s.initial_effect(c)
	-- 将「千年十字」（37613663）登记为这张卡效果文本中记载的卡名，用于相关‘卡名记述’的检索与判定。
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
	-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「千年十字」加入手卡。
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
	-- ③：这张卡只要在怪兽区域存在，不会被魔法·陷阱卡的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
-- 效果①的发动合法性判定：不取对象，只检查自己的魔法与陷阱区域是否有空位可放置这张卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前判定时，要求自己的魔法与陷阱区域存在至少1个可用空格，否则①不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果①处理：先确认这张卡仍与效果关联；再将它从手牌以表侧表示移动到自己的魔法与陷阱区域；移动成功后再赋予它“当作永续魔法卡使用”的类型变更效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡移动到自己的魔法与陷阱区域并表侧表示放置，且立即适用其效果；返回成功时才继续后续类型变更处理。
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
-- 效果②的发动条件：这张卡必须是‘当作永续魔法卡使用’的状态（当前类型等于永续魔法）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 定义展示代价筛选：手卡中存在卡号37613663且当前未给对方公开的「千年十字」。
function s.cfilter1(c,tp)
	return c:IsCode(37613663) and not c:IsPublic()
end
-- 效果②的代价处理：检查手牌「千年十字」与2000LP两个可选代价；若两者都可，询问玩家选择展示还是支付LP；选择展示或只能展示时，选1张「千年十字」给对方确认并洗切手牌；否则支付2000LP。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手牌中是否存在至少1张未公开的「千年十字」。
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查自己能否支付2000基本分作为代价。
	local b2=Duel.CheckLPCost(tp,2000)
	if chk==0 then return b1 or b2 end
	-- 当两种代价都可行时，弹出是否选择“出示「千年十字」”的询问。
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否出示「千年十字」？"
		-- 设置提示消息，让玩家选择一张要展示给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手牌选择1张未公开的「千年十字」，作为展示给对方确认的代价。
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的「千年十字」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切自己的手牌。
		Duel.ShuffleHand(tp)
	elseif b2 then
		-- 支付2000基本分作为发动代价。
		Duel.PayLPCost(tp,2000)
	else
		-- 设置提示消息，让玩家选择要展示给对方确认的「千年十字」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手牌选择1张未公开的「千年十字」用于展示。
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的「千年十字」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切自己的手牌。
		Duel.ShuffleHand(tp)
	end
end
-- 效果②的目标设定：发动时检查主怪兽区空位并确认这张卡能够作为怪兽特殊召唤；满足后把“特殊召唤这张卡”写入本次连锁的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的主要怪兽区有空位，且自己能够以5星·地属性·战士族·攻击力0/守备力3000的效果怪兽形式特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,0,3000,5,RACE_WARRIOR,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息：本次效果处理预定将这张卡本身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义检索筛选：选择卡组中卡号为37613663（千年十字）且能够加入手卡的卡。
function s.filter(c)
	return c:IsCode(37613663) and c:IsAbleToHand()
end
-- 效果②处理：先确认这张卡仍与效果关联并特殊召唤成功；之后若卡组有「千年十字」且玩家选择检索，则从中选1张加入手卡并向对方展示；检索前用Duel.BreakEffect确保‘那之后’的先后顺序。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 只有这张卡仍与效果关联、特殊召唤成功、卡组存在可检索的「千年十字」，且玩家同意检索时，才继续执行检索处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把「千年十字」加入手卡？"
		-- 设置提示消息，让玩家从卡组选择要加入手牌的「千年十字」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张符合条件的「千年十字」（此处只完成选择，下一步才加入手卡）。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 用Duel.BreakEffect中断当前效果处理，使后续的加入手卡与之前的特殊召唤不在同一时点处理，体现原文‘那之后’的顺序。
			Duel.BreakEffect()
			-- 将选中的「千年十字」以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的「千年十字」展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义③的免疫判定：若破坏效果来自魔法·陷阱卡，则返回真，使这张卡不会被该效果破坏。
function s.efilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
