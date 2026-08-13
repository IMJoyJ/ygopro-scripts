--竜の騎士
-- 效果：
-- 要让自己场上的卡破坏的效果由对方怪兽发动时，把成为对象的自己的卡全部送去墓地才能发动。这张卡从手卡特殊召唤。
function c38109772.initial_effect(c)
	-- 要让自己场上的卡破坏的效果由对方怪兽发动时，把成为对象的自己的卡全部送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38109772,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38109772.condition)
	e1:SetCost(c38109772.cost)
	e1:SetTarget(c38109772.target)
	e1:SetOperation(c38109772.operation)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
end
-- 过滤函数：判断卡片c是否为自己场上且是对方破坏效果的对象，用于从对象组中筛出自己会被破坏的卡。
function c38109772.filter(c,tp,dg)
	return c:IsControler(tp) and dg:IsContains(c)
end
-- 发动条件判定：仅在对方怪兽发动取对象的破坏效果且对象中包含自己场上的卡时为真，同时把筛选出的这些卡存入效果LabelObject以供代价使用。
function c38109772.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁的效果对象（取对象效果所选的卡片组）。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or tg:GetCount()==0 then return false end
	-- 取得该连锁效果的破坏操作信息，ex表示是否存在破坏分类，dg为可能被破坏的卡组，用于确认这是破坏效果。
	local ex,dg,dc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if not ex or not dg then return false end
	local cg=tg:Filter(c38109772.filter,nil,tp,dg)
	if cg:GetCount()>0 then
		e:GetLabelObject():Clear()
		e:GetLabelObject():Merge(cg)
		return true
	end
	return false
end
-- 代价处理：先检查LabelObject中所有卡都能作为代价送入墓地，可以则将其全部送入墓地作为发动代价。
function c38109772.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():FilterCount(Card.IsAbleToGraveAsCost,nil)==e:GetLabelObject():GetCount() end
	-- 将LabelObject中记录的自己场上的卡全部送入墓地（作为发动代价）。
	Duel.SendtoGrave(e:GetLabelObject(),REASON_COST)
end
-- 效果发动合法性与处理信息：确认特殊召唤可行后，设置将这张卡特殊召唤的操作信息。
function c38109772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetLabelObject():FilterCount(Card.IsLocation,nil,LOCATION_MZONE)
		-- 检查把LabelObject中位于怪兽区的卡送入墓地后自己是否有足够怪兽区空格，且此卡本身可以被特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-ct and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁处理信息：本次效果将特殊召唤1只怪兽（自己）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
-- 效果处理：若此卡仍与本次效果关联，则进行特殊召唤。
function c38109772.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
