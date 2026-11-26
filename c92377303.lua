--黒衣の大賢者
-- 效果：
-- 这张卡不能通常召唤。猜中自己的「时间魔术师」的掷硬币效果时，可以把自己场上存在的1只「黑魔术师」解放从手卡或者卡组中特殊召唤。这个方法特殊召唤成功时，从自己卡组把1张魔法卡加入手卡。
function c92377303.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「黑魔术师」。
	aux.AddCodeList(c,46986414)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。猜中自己的「时间魔术师」的掷硬币效果时，可以把自己场上存在的1只「黑魔术师」解放从手卡或者卡组中特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92377303,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECK_SPSUMMON)
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
-- 特殊召唤效果的发动条件：检查触发自定义「时间魔术师猜中硬币」事件的玩家是否为自己。
function c92377303.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 特殊召唤效果的发动代价：检查并把自己场上1只「黑魔术师」解放。
function c92377303.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认自己场上存在至少1只可解放的「黑魔术师」。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,46986414) end
	-- 让己方从自己场上选择1只「黑魔术师」准备解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,46986414)
	-- 将所选「黑魔术师」作为发动代价解放。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的目标处理函数：检查自己怪兽区空位及这张卡的无视召唤条件特招合法性，若从卡组发动则向对方展示并设置特招操作信息。
function c92377303.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己怪兽区至少有1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	if e:GetHandler():IsLocation(LOCATION_DECK) then
		-- 若这张卡是在卡组中发动，向对方展示确认这张卡。
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
	-- 设置操作信息：预计将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数：无视召唤条件将这张卡以表侧表示特殊召唤到自己场上，并标记完成正规召唤手续。
function c92377303.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 无视召唤条件将这张卡特殊召唤到自己场上，并判断是否特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 检索效果的发动条件：检查这张卡这次特殊召唤是否是由自身效果所引发的。
function c92377303.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==re:GetHandler()
end
-- 过滤条件：检查卡片是否为可以加入手卡的魔法卡。
function c92377303.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的目标处理函数：检查卡组是否存在可加入手卡的魔法卡，并设置加手卡操作信息。
function c92377303.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组存在至少1张可以加入手卡的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c92377303.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从自己卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数：从自己卡组选1张魔法卡加入手卡并展示给对方确认。
function c92377303.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，引导玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张可加入手卡的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c92377303.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选魔法卡以效果加入自己手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的魔法卡展示给对方确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
