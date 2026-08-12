--黄金卿エルドリッチ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1张魔法·陷阱卡送去墓地，以场上1张卡为对象才能发动。那张卡送去墓地。
-- ②：这张卡在墓地存在的场合，把自己场上1张魔法·陷阱卡送去墓地才能发动。这张卡加入手卡。那之后，可以从手卡把1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽直到对方回合结束时攻击力·守备力上升1000，不会被效果破坏。
function c95440946.initial_effect(c)
	-- ①：从手卡把这张卡和1张魔法·陷阱卡送去墓地，以场上1张卡为对象才能发动。那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95440946,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,95440946)
	e1:SetCost(c95440946.tgcost)
	e1:SetTarget(c95440946.tgtg)
	e1:SetOperation(c95440946.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己场上1张魔法·陷阱卡送去墓地才能发动。这张卡加入手卡。那之后，可以从手卡把1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽直到对方回合结束时攻击力·守备力上升1000，不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95440946,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,95440947)
	e2:SetCost(c95440946.thcost)
	e2:SetTarget(c95440946.thtg)
	e2:SetOperation(c95440946.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：魔法·陷阱卡且能作为代价送去墓地
function c95440946.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：从手卡把这张卡和1张魔法·陷阱卡送去墓地
function c95440946.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除这张卡以外的1张魔法·陷阱卡，且这张卡自身也能作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c95440946.costfilter,tp,LOCATION_HAND,0,1,c) and c:IsAbleToGraveAsCost() end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中除这张卡以外的1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c95440946.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备：以场上1张卡为对象
function c95440946.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 检查场上是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡（作为效果对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张可以送去墓地的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的效果处理：那张卡送去墓地
function c95440946.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 效果②的发动代价：把自己场上1张魔法·陷阱卡送去墓地
function c95440946.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以送去墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95440946.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c95440946.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的场上的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动准备：这张卡加入手卡
function c95440946.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置效果处理信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤条件：手卡中可以特殊召唤的不死族怪兽
function c95440946.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的效果处理：这张卡加入手卡，那之后可以从手卡特殊召唤1只不死族怪兽并赋予强化和抗性
function c95440946.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，且成功加入手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查手卡中是否存在可以特殊召唤的不死族怪兽
		and Duel.IsExistingMatchingCard(c95440946.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查怪兽区域是否有空位，并询问玩家是否进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(95440946,2)) then  --"是否把不死族怪兽特殊召唤？"
		-- 洗切手卡（因为加入了卡片且可能不进行特殊召唤，需要洗牌）
		Duel.ShuffleHand(tp)
		-- 中断效果处理，使后续的特殊召唤处理不与加入手卡视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择手卡中1只满足条件的不死族怪兽
		local tc=Duel.SelectMatchingCard(tp,c95440946.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		-- 尝试以表侧表示特殊召唤选中的怪兽
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽直到对方回合结束时攻击力·守备力上升1000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetRange(LOCATION_MZONE)
			e3:SetValue(1)
			tc:RegisterEffect(e3)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
