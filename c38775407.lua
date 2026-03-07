--千年の眠りから覚めし原人
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1只「千年」怪兽加入手卡。
-- ③：这张卡只要在怪兽区域存在，不会被怪兽的效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①当作魔法卡放置、②特殊召唤并检索、③不会被怪兽效果破坏
function s.initial_effect(c)
	-- 记录该卡拥有「千年十字」的卡名
	aux.AddCodeList(c,37613663)
	-- 效果①：在手卡时可发动，将此卡当作永续魔法卡放置于魔法与陷阱区域
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作魔法卡放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 效果②：当作永续魔法卡使用时可发动，支付2000LP或展示手牌1张「千年十字」，将此卡特殊召唤并检索1只「千年」怪兽
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
	-- 效果③：只要在怪兽区域存在，不会被怪兽的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判断，检查是否有魔法与陷阱区域的空位
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有魔法与陷阱区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果①的处理，将此卡移至魔法与陷阱区域并改变其类型为永续魔法
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡移至魔法与陷阱区域
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将此卡类型改为永续魔法
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件，检查此卡是否为永续魔法
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 过滤函数，用于判断手牌中是否有未公开的「千年十字」
function s.cfilter1(c,tp)
	return c:IsCode(37613663) and not c:IsPublic()
end
-- 效果②的费用支付，判断是否可以支付2000LP或展示手牌1张「千年十字」
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手牌中是否存在未公开的「千年十字」
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 判断玩家是否能支付2000LP
	local b2=Duel.CheckLPCost(tp,2000)
	if chk==0 then return b1 or b2 end
	-- 若同时满足展示「千年十字」和支付LP的条件，询问玩家是否展示「千年十字」
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否出示「千年十字」？"
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择手牌中1张「千年十字」进行确认
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方确认展示的卡
		Duel.ConfirmCards(1-tp,g)
		-- 将手牌洗切
		Duel.ShuffleHand(tp)
	elseif b2 then
		-- 支付2000LP
		Duel.PayLPCost(tp,2000)
	else
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择手牌中1张「千年十字」进行确认
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方确认展示的卡
		Duel.ConfirmCards(1-tp,g)
		-- 将手牌洗切
		Duel.ShuffleHand(tp)
	end
end
-- 效果②的发动条件判断，检查是否有怪兽区域的空位和是否可以特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有怪兽区域的空位和是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,2750,2500,8,RACE_BEASTWARRIOR,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息，准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断卡组中是否有「千年」怪兽
function s.filter(c)
	return c:IsSetCard(0x1ae) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的处理，特殊召唤此卡并检索「千年」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤和检索的条件
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把「千年」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择卡组中1只「千年」怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果③的过滤函数，用于判断是否为效果怪兽的效果
function s.efilter(e,re)
	return re:IsActiveType(TYPE_EFFECT)
end
