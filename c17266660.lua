--朱光の宣告者
-- 效果：
-- ①：对方把怪兽的效果发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
function c17266660.initial_effect(c)
	-- ①：对方把怪兽的效果发动时，从手卡把这张卡和1只天使族怪兽送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17266660,0))  --"效果怪兽的效果的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17266660.discon)
	e1:SetCost(c17266660.discost)
	e1:SetTarget(c17266660.distg)
	e1:SetOperation(c17266660.disop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：只有对方发动的效果是怪兽效果，且该连锁可以被无效化时，本效果才满足发动条件。
function c17266660.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前连锁是由对方发动的怪兽效果，且该连锁可被无效。
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- cost筛选函数：手卡中满足可作为代价送去墓地的天使族怪兽。
function c17266660.costfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- cost处理判定与执行：检查这张卡自身和手卡中是否存在1只天使族怪兽可作为代价，若可则发动时选择这些卡送去墓地。
function c17266660.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查手卡中是否存在至少1张除这张卡外的天使族怪兽，可作为cost对象。
		Duel.IsExistingMatchingCard(c17266660.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 给玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡中选择1张满足costfilter条件的怪兽（不包含这张卡自身）。
	local g=Duel.SelectMatchingCard(tp,c17266660.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的怪兽与这张卡一起从手卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标设定函数：判定效果是否合法发动，并登记本次操作的无效与破坏信息。
function c17266660.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果将使当前连锁的发动无效，对象为eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动效果的怪兽可被破坏且仍与该效果关联，则追加登记破坏该怪兽的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：执行发动无效，并在无效成功后，将对应的怪兽破坏。
function c17266660.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若连锁发动被无效成功，且对方发动效果的怪兽仍然与效果关联，才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将引发该效果的怪兽以效果原因破坏送去墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
