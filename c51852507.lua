--薔薇の聖弓手
-- 效果：
-- 自己场上有植物族怪兽存在，对方把陷阱卡发动时，把这张卡从手卡送去墓地才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
function c51852507.initial_effect(c)
	-- 自己场上有植物族怪兽存在，对方把陷阱卡发动时，把这张卡从手卡送去墓地才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51852507,0))  --"陷阱无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c51852507.discon)
	e1:SetCost(c51852507.discost)
	e1:SetTarget(c51852507.distg)
	e1:SetOperation(c51852507.disop)
	c:RegisterEffect(e1)
end
-- 过滤函数，判定卡片是否为表侧表示且种族为植物族，用于检索自己场上符合条件（表侧植物族）的怪兽。
function c51852507.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果发动条件：对方把陷阱卡发动，且该连锁可被无效，并且自己场上有表侧植物族怪兽存在时才满足发动条件。
function c51852507.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 前半部分条件：该连锁的发动者不是自己、发动的是陷阱卡且属于魔法陷阱卡的发动（EFFECT_TYPE_ACTIVATE），并且该连锁可以被无效。
	return ep~=tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 后半部分条件：自己场上存在至少1张表侧表示的植物族怪兽。
		and Duel.IsExistingMatchingCard(c51852507.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价函数：检查手卡中的这张卡能否作为代价送去墓地；若可以，则执行将这张卡从手卡送去墓地作为发动代价。
function c51852507.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动时的目标设定与操作信息登记：发动时不需要选择对象，登记“无效发动”的操作信息；若对方陷阱卡可被破坏且仍与发动效果关联，则额外登记“破坏”的操作信息。
function c51852507.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁中的陷阱卡作为“无效发动”要处理的对象（数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：在满足可破坏且关联的条件下，将当前连锁中的陷阱卡作为“破坏”要处理的对象（数量为1）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：实际执行无效对方陷阱卡的发动，并在满足条件时将其破坏。
function c51852507.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 先尝试无效对方连锁的发动（Duel.NegateActivation），并确认该陷阱卡仍与该效果关联（未被移除或离场），只有这样才能继续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的那张陷阱卡破坏，破坏原因为效果（REASON_EFFECT）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
