--黒衣の大賢者
-- 效果：
-- 这张卡不能通常召唤。猜中自己的「时间魔术师」的掷硬币效果时，可以把自己场上存在的1只「黑魔术师」解放从手卡或者卡组中特殊召唤。这个方法特殊召唤成功时，从自己卡组把1张魔法卡加入手卡。
function c92377303.initial_effect(c)
	-- 记录该卡片记有「黑魔术师」的卡名。
	aux.AddCodeList(c,46986414)
	c:EnableReviveLimit()
	-- 猜中自己的「时间魔术师」的掷硬币效果时，可以把自己场上存在的1只「黑魔术师」解放从手卡或者卡组中特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92377303,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCode(EVENT_CUSTOM+71625222)
	e1:SetCondition(c92377303.spcon)
	e1:SetCost(c92377303.cost)
	e1:SetTarget(c92377303.sptg)
	e1:SetOperation(c92377303.spop)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，从自己卡组把1张魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92377303,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c92377303.thcon)
	e3:SetTarget(c92377303.thtg)
	e3:SetOperation(c92377303.thop)
	c:RegisterEffect(e3)
end
-- 检查触发自定义事件的玩家是否为自己（即自己猜中「时间魔术师」的掷硬币效果）。
function c92377303.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 特殊召唤效果的发动代价：解放自己场上1只「黑魔术师」。
function c92377303.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「黑魔术师」。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,46986414) end
	-- 玩家选择自己场上1只「黑魔术师」作为解放的卡。
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,46986414)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位、自身是否能特殊召唤，并设置操作信息）。
function c92377303.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	if e:GetHandler():IsLocation(LOCATION_DECK) then
		-- 若此卡在卡组中发动，则向对方玩家展示此卡。
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
	-- 设置连锁信息，表示该效果包含特殊召唤此卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理：将此卡特殊召唤并完成正规召唤程序。
function c92377303.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将此卡以表侧表示特殊召唤（无视召唤条件）。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 检查触发特殊召唤成功时点的效果是否是由此卡自身的效果所导致的特殊召唤。
function c92377303.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==re:GetHandler()
end
-- 过滤条件：卡组中的魔法卡且能加入手牌。
function c92377303.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的发动准备（检查卡组中是否存在魔法卡，并设置检索的操作信息）。
function c92377303.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足条件的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c92377303.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理：从卡组选择1张魔法卡加入手牌并给对方确认。
function c92377303.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足过滤条件的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c92377303.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
