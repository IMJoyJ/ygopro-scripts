--千年王朝の盾
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「千年十字」加入手卡。
-- ③：这张卡只要在怪兽区域存在，不会被魔法·陷阱卡的效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码37613663（千年十字）
	aux.AddCodeList(c,37613663)
	-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「千年十字」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
-- 效果处理函数：判断是否可以将卡片移至魔法与陷阱区域
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的魔法与陷阱区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果处理函数：将卡片移至魔法与陷阱区域并改变其类型
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片移动到玩家的魔法与陷阱区域
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将卡片类型更改为永续魔法卡
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 判断卡片是否为永续魔法卡的条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 判断手牌中是否存在未公开的千年十字
function s.cfilter1(c,tp)
	return c:IsCode(37613663) and not c:IsPublic()
end
-- 效果处理函数：支付特殊召唤所需费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在未公开的千年十字
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查玩家是否能支付2000基本分
	local b2=Duel.CheckLPCost(tp,2000)
	if chk==0 then return b1 or b2 end
	-- 若同时满足支付LP和手牌有千年十字，则由玩家选择支付方式
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 提示玩家选择确认手牌中的千年十字
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		-- 选择玩家手牌中的一张千年十字
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方玩家展示所选的千年十字
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
	elseif b2 then
		-- 支付2000基本分
		Duel.PayLPCost(tp,2000)
	else
		-- 提示玩家选择确认手牌中的千年十字
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		-- 选择玩家手牌中的一张千年十字
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方玩家展示所选的千年十字
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
	end
end
-- 效果处理函数：设置特殊召唤及检索的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以特殊召唤该怪兽并有千年十字可检索
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,0,3000,5,RACE_WARRIOR,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息：特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 检索卡组中千年十字的过滤函数
function s.filter(c)
	return c:IsCode(37613663) and c:IsAbleToHand()
end
-- 效果处理函数：执行特殊召唤及检索操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤及检索的条件
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		-- 提示玩家选择从卡组检索千年十字
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从卡组中选择一张千年十字
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的千年十字加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的千年十字
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断效果是否被魔法或陷阱卡破坏
function s.efilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
