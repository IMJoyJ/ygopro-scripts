--ミラーフォース・ランチャー
-- 效果：
-- ①：1回合1次，自己主要阶段从手卡丢弃1只怪兽才能发动。从自己的卡组·墓地选1张「神圣防护罩 -反射镜力-」加入手卡。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合才能发动。选墓地的这张卡和自己的手卡·卡组·墓地1张「神圣防护罩 -反射镜力-」，那张卡和这张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c29649320.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段从手卡丢弃1只怪兽才能发动。从自己的卡组·墓地选1张「神圣防护罩 -反射镜力-」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c29649320.thcon)
	e2:SetCost(c29649320.thcost)
	e2:SetTarget(c29649320.thtg)
	e2:SetOperation(c29649320.thop)
	c:RegisterEffect(e2)
	-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合才能发动。选墓地的这张卡和自己的手卡·卡组·墓地1张「神圣防护罩 -反射镜力-」，那张卡和这张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c29649320.setcon)
	e3:SetTarget(c29649320.settg)
	e3:SetOperation(c29649320.setop)
	c:RegisterEffect(e3)
end
-- 判断是否为自己的主要阶段1或主要阶段2
function c29649320.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
		-- 判断是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤手卡中可以丢弃的怪兽
function c29649320.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 支付效果的代价：丢弃1只手卡中的怪兽
function c29649320.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29649320.thcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡中的1只怪兽的操作
	Duel.DiscardHand(tp,c29649320.thcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组或墓地中可以加入手牌的「神圣防护罩 -反射镜力-」
function c29649320.thfilter(c)
	return c:IsCode(44095762) and c:IsAbleToHand()
end
-- 设置效果的目标：从卡组或墓地检索1张「神圣防护罩 -反射镜力-」
function c29649320.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在可以加入手牌的「神圣防护罩 -反射镜力-」
	if chk==0 then return Duel.IsExistingMatchingCard(c29649320.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：将1张「神圣防护罩 -反射镜力-」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行效果：选择并加入手牌
function c29649320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「神圣防护罩 -反射镜力-」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29649320.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足效果发动条件：盖放的这张卡被对方的效果破坏送去墓地
function c29649320.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤手卡、卡组或墓地中可以盖放的「神圣防护罩 -反射镜力-」
function c29649320.setfilter(c)
	return c:IsCode(44095762) and c:IsSSetable()
end
-- 设置效果的目标：选择1张「神圣防护罩 -反射镜力-」盖放
function c29649320.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的盖放区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 检查手卡、卡组或墓地中是否存在可以盖放的「神圣防护罩 -反射镜力-」
		and e:GetHandler():IsSSetable() and Duel.IsExistingMatchingCard(c29649320.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 执行效果：选择并盖放卡牌
function c29649320.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足盖放条件：场上是否有足够的盖放区域且卡牌有效
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 or not c:IsRelateToEffect(e) or not c:IsSSetable() then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的「神圣防护罩 -反射镜力-」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29649320.setfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local sg=Group.FromCards(c,tc)
		-- 执行盖放操作
		if Duel.SSet(tp,sg)==0 then return end
		-- 使盖放的卡在盖放的回合也能发动
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(29649320,0))  --"适用「反射镜力启动」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
