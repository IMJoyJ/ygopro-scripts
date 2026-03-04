--ティンダングル・トリニティ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1只「廷达魔三角之底边守卫者」特殊召唤。
-- ②：只要反转过的这张卡在怪兽区域存在，自己的「廷达魔三角」怪兽不会被战斗破坏。
-- ③：这张卡作为「廷达魔三角」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「热尔岗终焉」加入手卡，从卡组把1张魔法·陷阱卡送去墓地。
function c11375683.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1只「廷达魔三角之底边守卫者」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11375683,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c11375683.sptg)
	e1:SetOperation(c11375683.spop)
	c:RegisterEffect(e1)
	-- ②：只要反转过的这张卡在怪兽区域存在，自己的「廷达魔三角」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c11375683.flipop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为「廷达魔三角」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「热尔岗终焉」加入手卡，从卡组把1张魔法·陷阱卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为「廷达魔三角」卡组
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10b))
	e3:SetCondition(c11375683.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡作为「廷达魔三角」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「热尔岗终焉」加入手卡，从卡组把1张魔法·陷阱卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11375683,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,11375683)
	e4:SetCondition(c11375683.thcon)
	e4:SetTarget(c11375683.thtg)
	e4:SetOperation(c11375683.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为「廷达魔三角之底边守卫者」
function c11375683.spfilter(c,e,tp)
	return c:IsCode(94365540) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判断函数，用于判断是否满足特殊召唤条件
function c11375683.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件，检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤条件，检查卡组中是否存在「廷达魔三角之底边守卫者」
		and Duel.IsExistingMatchingCard(c11375683.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行特殊召唤操作
function c11375683.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件，检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索满足条件的「廷达魔三角之底边守卫者」
	local tc=Duel.GetFirstMatchingCard(c11375683.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的「廷达魔三角之底边守卫者」特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 反转效果处理函数，用于记录反转状态
function c11375683.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11375683,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判断是否满足战斗破坏免疫条件，检查是否反转过
function c11375683.indcon(e)
	return e:GetHandler():GetFlagEffect(11375683)~=0
end
-- 效果发动条件判断函数，用于判断是否作为连接素材送去墓地
function c11375683.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x10b)
end
-- 过滤函数，用于判断是否为「热尔岗终焉」
function c11375683.thfilter(c,tp)
	return c:IsCode(59490397) and c:IsAbleToHand()
		-- 检查卡组中是否存在魔法或陷阱卡
		and Duel.IsExistingMatchingCard(c11375683.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤函数，用于判断是否为魔法或陷阱卡
function c11375683.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果处理时的判断函数，用于判断是否满足检索条件
function c11375683.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，检查卡组中是否存在「热尔岗终焉」
	if chk==0 then return Duel.IsExistingMatchingCard(c11375683.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息，表示将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行检索和送去墓地操作
function c11375683.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张「热尔岗终焉」
	local hg=Duel.SelectMatchingCard(tp,c11375683.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 将选择的卡加入手牌
	if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0
		and hg:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,hg)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		-- 从卡组中选择1张魔法或陷阱卡
		local g=Duel.SelectMatchingCard(tp,c11375683.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
