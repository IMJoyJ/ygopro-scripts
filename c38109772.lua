--竜の騎士
-- 效果：
-- 要让自己场上的卡破坏的效果由对方怪兽发动时，把成为对象的自己的卡全部送去墓地才能发动。这张卡从手卡特殊召唤。
function c38109772.initial_effect(c)
	-- 效果原文：要让自己场上的卡破坏的效果由对方怪兽发动时，把成为对象的自己的卡全部送去墓地才能发动。这张卡从手卡特殊召唤。
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
-- 效果作用：过滤目标卡片中属于玩家tp且在破坏对象组dg中的卡片
function c38109772.filter(c,tp,dg)
	return c:IsControler(tp) and dg:IsContains(c)
end
-- 效果作用：判断连锁是否满足条件，即对方怪兽发动的效果为怪兽类型、具有取对象属性、且其对象卡片中有我方场上的卡
function c38109772.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 效果作用：获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or tg:GetCount()==0 then return false end
	-- 效果作用：获取当前连锁的破坏效果信息
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
-- 效果作用：检查是否可以支付费用，若可以则将标签对象中的所有卡片送去墓地作为费用
function c38109772.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():FilterCount(Card.IsAbleToGraveAsCost,nil)==e:GetLabelObject():GetCount() end
	-- 效果作用：将标签对象中的所有卡片送去墓地作为费用
	Duel.SendtoGrave(e:GetLabelObject(),REASON_COST)
end
-- 效果作用：设置特殊召唤的处理信息，判断是否满足特殊召唤条件
function c38109772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetLabelObject():FilterCount(Card.IsLocation,nil,LOCATION_MZONE)
		-- 效果作用：判断我方场上是否有足够的召唤区域来特殊召唤此卡
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-ct and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 效果作用：设置当前处理的连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
-- 效果作用：执行特殊召唤操作，将此卡从手卡特殊召唤到场上
function c38109772.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 效果作用：将此卡以正面表示的形式特殊召唤到我方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
