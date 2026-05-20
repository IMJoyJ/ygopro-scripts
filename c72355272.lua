--メタファイズ・ネフティス
-- 效果：
-- ①：这张卡用「玄化」怪兽的效果特殊召唤成功的场合才能发动。场上盖放的魔法·陷阱卡全部除外。
-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从卡组把「玄化奈芙提斯」以外的1张「玄化」卡加入手卡。
function c72355272.initial_effect(c)
	-- ①：这张卡用「玄化」怪兽的效果特殊召唤成功的场合才能发动。场上盖放的魔法·陷阱卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72355272,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c72355272.rmcon)
	e1:SetTarget(c72355272.rmtg)
	e1:SetOperation(c72355272.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从卡组把「玄化奈芙提斯」以外的1张「玄化」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72355272,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c72355272.thcon)
	e2:SetCost(c72355272.thcost)
	e2:SetTarget(c72355272.thtg)
	e2:SetOperation(c72355272.thop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是由「玄化」怪兽的效果特殊召唤成功。
function c72355272.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x105)
end
-- 过滤场上盖放的（里侧表示的）魔法·陷阱卡，且该卡可以被除外。
function c72355272.rmfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果①的发动准备与效果分类确认，检查场上是否存在可以除外的盖放魔陷，并设置除外操作信息。
function c72355272.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上除这张卡以外的所有盖放的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c72355272.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 设置连锁处理的操作信息为：除外场上所有符合条件的盖放魔陷。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的效果处理，将场上盖放的魔法·陷阱卡全部除外。
function c72355272.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除这张卡以外的所有盖放的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c72355272.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 以效果原因将目标卡片组以表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 检查当前回合是否为这张卡被除外回合的下个回合。
function c72355272.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于这张卡被除外时的回合数加1（即下个回合）。
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- 效果②的发动代价，将除外的这张卡回到持有者卡组并洗牌。
function c72355272.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 作为发动代价，将这张卡送回卡组并洗牌。
	Duel.SendtoDeck(e:GetHandler(),tp,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤卡组中「玄化奈芙提斯」以外的「玄化」卡片，且该卡可以加入手牌。
function c72355272.thfilter(c)
	return c:IsSetCard(0x105) and not c:IsCode(72355272) and c:IsAbleToHand()
end
-- 效果②的发动准备与效果分类确认，检查卡组中是否存在可检索的「玄化」卡，并设置检索操作信息。
function c72355272.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足条件的「玄化」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c72355272.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理，从卡组选择1张「玄化」卡加入手牌，并给对方确认。
function c72355272.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「玄化」卡。
	local g=Duel.SelectMatchingCard(tp,c72355272.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
