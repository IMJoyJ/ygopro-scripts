--真なる太陽神
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，除「真正的太阳神」外的1只「太阳神之翼神龙」或者1张有那个卡名记述的卡从卡组加入手卡。
-- ②：「太阳神之翼神龙」以外的特殊召唤的怪兽在那个回合不能攻击。
-- ③：1回合1次，自己主要阶段才能发动。这张卡或者卡组1只「太阳神之翼神龙-不死鸟」送去墓地。那之后，选自己场上1只「太阳神之翼神龙」送去墓地。
local s,id,o=GetID()
-- 注册这张卡的全部效果：①发动时的检索、②限制攻击的永续效果、③起动送墓效果。
function s.initial_effect(c)
	-- 记录本卡效果文中记述了卡名“太阳神之翼神龙”（卡号10000010），以便用 aux.IsCodeOrListed 精确检索相关卡。
	aux.AddCodeList(c,10000010)
	-- ①：作为这张卡的发动时的效果处理，除「真正的太阳神」外的1只「太阳神之翼神龙」或者1张有那个卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：「太阳神之翼神龙」以外的特殊召唤的怪兽在那个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.attg)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。这张卡或者卡组1只「太阳神之翼神龙-不死鸟」送去墓地。那之后，选自己场上1只「太阳神之翼神龙」送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 定义效果①的检索过滤函数：符合条件的卡为“太阳神之翼神龙”或记述了该卡名的卡，且不能是本卡（真正的太阳神），并可以加入手卡。
function s.filter(c)
	-- 过滤条件：满足 aux.IsCodeOrListed(c,10000010)（是翼神龙或记述其名）、不是本卡、可以加入手卡。
	return aux.IsCodeOrListed(c,10000010) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 效果①的发动条件检测与操作信息设置：若卡组存在符合条件的卡则可发动，并登记“加入手卡”的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认卡组中存在至少1张满足 s.filter 的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本效果处理时将1张卡从卡组加入手卡的操作信息，供连锁中相关效果（如星尘龙）检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：玩家从卡组选择1张符合条件的卡加入手卡，并让对手确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选出1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（通常是自己）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的目标判定：本回合特殊召唤过、且卡名不是“太阳神之翼神龙”的怪兽适用不能攻击的限制。
function s.attg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and not c:IsCode(10000010)
end
-- 效果③第一段送墓候选的过滤：卡组中卡号为10000090的“太阳神之翼神龙-不死鸟”，且可以送去墓地。
function s.tgfilter1(c)
	return c:IsAbleToGrave() and c:IsCode(10000090)
end
-- 效果③第二段送墓对象的过滤：自己场上表侧表示的卡号为10000010的“太阳神之翼神龙”，且可以送去墓地。
function s.tgfilter2(c)
	return c:IsAbleToGrave() and c:IsCode(10000010) and c:IsFaceup()
end
-- 效果③的发动条件：本卡自身可以送墓或卡组存在可送墓的“不死鸟”，并且自己场上存在可送墓的“太阳神之翼神龙”。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (e:GetHandler():IsAbleToGrave()
			-- 本分支判断卡组中是否有符合条件的“太阳神之翼神龙-不死鸟”可送去墓地。
			or Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil))
		-- 同时判断自己场上是否有符合条件的“太阳神之翼神龙”可送去墓地。
		and Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置效果③将2张卡送去墓地的操作信息（来源为场上或卡组，具体对象不确定故传nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_MZONE+LOCATION_DECK)
end
-- 效果③的处理：先选这张卡或卡组中的“不死鸟”送墓；若成功，再选自己场上1只“太阳神之翼神龙”送墓。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得卡组中所有符合条件的“太阳神之翼神龙-不死鸟”，并（若本卡仍可送墓）把本卡也加入候选集合，供玩家选择。
	local g=Duel.GetMatchingGroup(s.tgfilter1,tp,LOCATION_DECK,0,nil)
	if c:IsRelateToChain() and c:IsAbleToGrave() then g:AddCard(c) end
	-- 弹出选择提示，让玩家选择第一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg1=g:Select(tp,1,1,nil)
	-- 将第一张选中的卡以效果送去墓地；仅当送墓成功且该卡确实在墓地时，才继续处理后续送墓。
	if Duel.SendtoGrave(sg1,REASON_EFFECT)>0 and sg1:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 再次弹出选择提示，让玩家选择场上要送去墓地的“太阳神之翼神龙”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择自己场上1只表侧表示且符合条件的“太阳神之翼神龙”。
		local sg2=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		if #sg2>0 then
			-- 中断当前效果链，使“翼神龙”被送墓的时点不会被前一个送墓动作的连锁错过。
			Duel.BreakEffect()
			-- 将选中的“太阳神之翼神龙”以效果送去墓地。
			Duel.SendtoGrave(sg2,REASON_EFFECT)
		end
	end
end
