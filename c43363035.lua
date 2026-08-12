--地下牢の徊神
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡从卡组送去墓地的场合发动（双方不能对应这个效果的发动把怪兽的效果发动）。自己场上的卡全部送去墓地，这张卡特殊召唤。那之后，把最多有这个效果送去墓地的卡数量的对方场上的卡送去墓地。
-- ②：这张卡从卡组以外送去墓地的场合，把1张手卡送去墓地才能发动。场上1张卡送去墓地。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①效果为诱发必发，②效果为诱发选发
function s.initial_effect(c)
	-- ①：这张卡从卡组送去墓地的场合发动（双方不能对应这个效果的发动把怪兽的效果发动）。自己场上的卡全部送去墓地，这张卡特殊召唤。那之后，把最多有这个效果送去墓地的卡数量的对方场上的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组以外送去墓地的场合，把1张手卡送去墓地才能发动。场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送墓效果"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡是从卡组送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 效果①的发动时处理：将自己场上的所有卡送去墓地，然后将自身特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 设置操作信息：将自己场上的所有卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,sg:GetCount(),0,0)
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁限制：不能连锁怪兽效果
	Duel.SetChainLimit(s.climit)
end
-- 连锁限制函数：如果效果的持有者不是怪兽卡，则可以连锁
function s.climit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_MONSTER)
end
-- 效果①的处理：将自己场上的所有卡送去墓地，然后将自身特殊召唤，再将对方场上等量的卡送去墓地
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 将自己场上的所有卡送去墓地
	if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		-- 获取实际被操作的卡组
		local g=Duel.GetOperatedGroup()
		local ct=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
		-- 如果送去墓地的卡数量不为0，且自身还在场上，且特殊召唤成功，则继续处理
		if ct~=0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 检查对方场上是否存在可送去墓地的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 选择对方场上的卡送去墓地，数量为之前送去墓地的卡数量
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,ct,nil)
			-- 显示被选为对象的卡
			Duel.HintSelection(tg)
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：这张卡不是从卡组送去墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 效果②的发动时处理：支付1张手卡送去墓地的费用，然后选择场上1张卡送去墓地
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为费用送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手卡送去墓地作为费用
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的目标设定：选择场上1张卡送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置操作信息：选择场上1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
-- 效果②的处理：选择场上1张卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张卡送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
