--スプライト・スプリンド
-- 效果：
-- 包含2星·2阶·连接2的怪兽在内的怪兽2只
-- 这张卡在连接召唤的回合不能作为连接素材。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1只2星怪兽送去墓地。
-- ②：这张卡在怪兽区域存在的状态，怪兽特殊召唤的场合，把自己场上1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
function c72329844.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：怪兽2只，且需满足包含2星·2阶·连接2怪兽的过滤条件。
	aux.AddLinkProcedure(c,nil,2,2,c72329844.lcheck)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c72329844.lmlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1只2星怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72329844,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,72329844)
	e2:SetCondition(c72329844.tgcon)
	e2:SetTarget(c72329844.tgtg)
	e2:SetOperation(c72329844.tgop)
	c:RegisterEffect(e2)
	-- ②：这张卡在怪兽区域存在的状态，怪兽特殊召唤的场合，把自己场上1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72329844,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,72329844)
	e3:SetCondition(c72329844.thcon)
	e3:SetCost(c72329844.thcost)
	e3:SetTarget(c72329844.thtg)
	e3:SetOperation(c72329844.thop)
	c:RegisterEffect(e3)
end
-- 检查连接素材中是否存在至少1只2星、2阶或连接2的怪兽。
function c72329844.lcheck(g,lc)
	return g:IsExists(Card.IsLevel,1,nil,2) or g:IsExists(Card.IsRank,1,nil,2) or g:IsExists(Card.IsLink,1,nil,2)
end
-- 检查自身是否处于连接召唤成功的回合，用于限制不能作为连接素材。
function c72329844.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检查此卡是否是通过连接召唤成功，作为效果①的发动条件。
function c72329844.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中可以送去墓地的2星怪兽。
function c72329844.tgfilter(c)
	return c:IsLevel(2) and c:IsAbleToGrave()
end
-- 效果①的发动准备：检查卡组中是否存在可送去墓地的2星怪兽，并设置送去墓地的操作信息。
function c72329844.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在至少1只可以送去墓地的2星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c72329844.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1只2星怪兽送去墓地。
function c72329844.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从己方卡组选择1只满足条件的2星怪兽。
	local g=Duel.SelectMatchingCard(tp,c72329844.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 检查特殊召唤的怪兽中是否不包含自身，作为效果②的发动条件。
function c72329844.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
-- 效果②的代价处理：检查并去除自己场上的1个超量素材。
function c72329844.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1个可以作为代价去除的超量素材。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 去除自己场上的1个超量素材。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 效果②的发动准备：选择场上1只怪兽作为对象，并设置回到手牌的操作信息。
function c72329844.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 检查场上是否存在至少1只可以回到手牌的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上1只可以回到手牌的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：将选中的对象怪兽送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将选中的对象怪兽送回手牌。
function c72329844.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽因效果送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
