--大嵐
-- 效果：
-- ①：场上的魔法·陷阱卡全部破坏。
function c19613556.initial_effect(c)
	-- ①：场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19613556.target)
	e1:SetOperation(c19613556.activate)
	c:RegisterEffect(e1)
end
-- 判断一张卡是否为魔法卡或陷阱卡，是则返回真，用于筛选场上要被破坏的魔法·陷阱卡。
function c19613556.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的条件判定与连锁信息登记：检查场上是否存在除自身以外的魔法·陷阱卡，若存在则登记将破坏这些卡的操作信息。
function c19613556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动前（chk==0）检查场上是否存在至少1张除自身以外的魔法·陷阱卡，作为能否发动此卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c19613556.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除自身以外的所有魔法·陷阱卡，作为之后要破坏的候选集合。
	local sg=Duel.GetMatchingGroup(c19613556.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 将破坏这些候选卡的操作信息写入当前连锁，类别为破坏，目标为候选集合，数量为其张数，供其他卡片进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理时执行破坏：再次选取场上除自身以外的所有魔法·陷阱卡，并将它们全部破坏。
function c19613556.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取场上除自身以外的所有魔法·陷阱卡，作为本次实际破坏的对象集合。
	local sg=Duel.GetMatchingGroup(c19613556.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因将这些魔法·陷阱卡全部破坏（不取对象，不指定玩家）。
	Duel.Destroy(sg,REASON_EFFECT)
end
