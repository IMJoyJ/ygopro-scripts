--氷結界の龍胤 エクハジャール
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡同调召唤的场合，丢弃1张手卡才能发动。对方的场上·墓地的卡选2张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽特殊召唤的场合，把自己的手卡1张除外才能发动。场上·墓地1张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡在怪兽区域存在，对方回合送去墓地的场合才能发动。对方手卡随机选1张除外，或对方场上·墓地的卡选1张除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon2)
	e3:SetTarget(s.rmtg2)
	e3:SetOperation(s.rmop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：同调召唤成功
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤手牌可丢弃的卡或可除外的代破卡
function s.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(18319762,tp)
	end
end
-- ①效果的代价：丢弃1张手牌或除外替代卡
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在满足代价条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择要丢弃或除外的代价卡片
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 适用替代效果将墓地的卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将手牌送去墓地作为代价
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- ①效果的目标：检查对方场上·墓地是否存在至少2张卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上·墓地是否有至少2张可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,2,nil) end
	-- 获取对方场上·墓地所有可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- ①效果的处理：选对方场上·墓地2张卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上·墓地不受王家长眠之谷影响的可除外卡片
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if g:GetCount()>=2 then
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 显示选中的卡片
		Duel.HintSelection(sg)
		-- 将选中的卡表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：对方特殊召唤怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- ②效果的代价：把手牌1张卡除外
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否有可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要除外的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手牌选择1张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标：检查场上·墓地是否有可回手牌的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上·墓地是否存在可返回手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 设置返回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ②效果的处理：选场上·墓地1张卡返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 优先从场上选择1张可返回手牌的卡
	local g=aux.SelectCardFromFieldFirst(tp,aux.NecroValleyFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中的卡片
		Duel.HintSelection(g)
		-- 将选择的卡返回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ③效果的发动条件：同调召唤的自身在对方回合从怪兽区送去墓地
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查送去墓地前是否在怪兽区、是否同调召唤且为对方回合
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.GetTurnPlayer()==1-tp
end
-- ③效果的目标：检查对方手牌·场上·墓地是否有可除外的卡
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌·场上·墓地是否有可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 设置除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ③效果的处理：随机除外对方手卡1张或除外场上·墓地1张卡
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中可除外的卡
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 获取对方场上·墓地中可除外的卡
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 选择是否随机除外对方手牌
	if g1:GetCount()>0 and (g2:GetCount()==0 or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		local sg1=g1:RandomSelect(tp,1)
		-- 显示选中的手牌
		Duel.HintSelection(sg1)
		-- 将选中的手牌表侧表示除外
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
	elseif g2:GetCount()>0 then
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 优先从场上选择对方场上·墓地的卡
		local sg2=aux.SelectCardFromFieldFirst(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
		-- 显示选中的卡片
		Duel.HintSelection(sg2)
		-- 将选中的卡表侧表示除外
		Duel.Remove(sg2,POS_FACEUP,REASON_EFFECT)
	end
end
