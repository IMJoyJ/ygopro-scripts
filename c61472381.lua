--巧炎星－エランセイ
-- 效果：
-- 「炎舞-「洞明」」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只怪兽才能发动。从自己的卡组·墓地选1张「炎舞」魔法·陷阱卡在自己场上盖放。
-- ②：对方把怪兽的效果发动时，把「巧炎星-巨羚青」以外的自己场上的表侧表示的1张「炎星」卡或者「炎舞」卡送去墓地才能发动。那个效果无效。
function c61472381.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：从手卡丢弃1只怪兽才能发动。从自己的卡组·墓地选1张「炎舞」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61472381,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,61472381)
	e1:SetCost(c61472381.setcost)
	e1:SetTarget(c61472381.settg)
	e1:SetOperation(c61472381.setop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，把「巧炎星-巨羚青」以外的自己场上的表侧表示的1张「炎星」卡或者「炎舞」卡送去墓地才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61472381,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61472382)
	e2:SetCondition(c61472381.discon)
	e2:SetCost(c61472381.discost)
	e2:SetTarget(c61472381.distg)
	e2:SetOperation(c61472381.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以丢弃的怪兽卡
function c61472381.costfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ①效果的Cost：从手卡丢弃1只怪兽
function c61472381.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61472381.costfilter1,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中的怪兽
	Duel.DiscardHand(tp,c61472381.costfilter1,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组或墓地中可以盖放的「炎舞」魔法·陷阱卡
function c61472381.setfilter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的Target：检查卡组或墓地中是否存在可以盖放的「炎舞」魔法·陷阱卡
function c61472381.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在至少1张可以盖放的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c61472381.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ①效果的Operation：从卡组或墓地选择1张「炎舞」魔法·陷阱卡在自己场上盖放
function c61472381.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要盖放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「炎舞」魔法·陷阱卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61472381.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- ②效果的Condition：对方发动怪兽效果时，且此卡未被战斗破坏，且该效果可以被无效
function c61472381.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身未被战斗破坏、发动者为对方、发动的是怪兽效果，且该效果可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 过滤条件：自己场上表侧表示的「巧炎星-巨羚青」以外的「炎星」卡或「炎舞」卡
function c61472381.costfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x79,0x7c) and not c:IsCode(61472381) and c:IsAbleToGraveAsCost()
end
-- ②效果的Cost：将自己场上表侧表示的1张「炎星」或「炎舞」卡送去墓地（若「炎星仙-鹫真人」效果适用中则可以不支付）
function c61472381.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可作为Cost送去墓地的卡，或者「炎星仙-鹫真人」的效果是否适用
	if chk==0 then return Duel.IsExistingMatchingCard(c61472381.costfilter2,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 如果场上有可送去墓地的卡，且不适用「炎星仙-鹫真人」的免Cost效果或玩家选择不免除Cost
	if Duel.IsExistingMatchingCard(c61472381.costfilter2,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 设置选择卡片时的提示信息为“请选择要送去墓地的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择场上1张表侧表示的「巧炎星-巨羚青」以外的「炎星」卡或「炎舞」卡
		local g=Duel.SelectMatchingCard(tp,c61472381.costfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡作为发动代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- ②效果的Target：设置效果无效的操作信息
function c61472381.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的Operation：使该发动效果无效
function c61472381.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
