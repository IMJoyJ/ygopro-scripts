--黄竜の忍者
-- 效果：
-- 这张卡不用「忍者」怪兽或者「忍法」卡的效果不能特殊召唤。
-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1只「忍者」怪兽和1张「忍法」卡送去墓地，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。这个效果在对方回合也能发动。
function c90247311.initial_effect(c)
	-- 这张卡不用「忍者」怪兽或者「忍法」卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c90247311.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1只「忍者」怪兽和1张「忍法」卡送去墓地，以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90247311,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c90247311.cost)
	e2:SetTarget(c90247311.target)
	e2:SetOperation(c90247311.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤限制：判定是否为「忍者」怪兽或「忍法」卡的效果
function c90247311.splimit(e,se,sp,st)
	return (se:IsActiveType(TYPE_MONSTER) and se:GetHandler():IsSetCard(0x2b)) or se:GetHandler():IsSetCard(0x61)
end
-- 发动代价：由于需要同时检测代价和对象，在cost中将Label设为1以标记需要进行代价检测
function c90247311.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤条件：手牌或场上表侧表示的「忍者」怪兽或「忍法」卡，且能送去墓地
function c90247311.cfilter(c)
	return ((c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b)) or c:IsSetCard(0x61))
		and (c:IsFaceup() or not c:IsOnField())
		and c:IsAbleToGraveAsCost()
end
-- 过滤条件：场上的魔法·陷阱卡，且能成为效果对象
function c90247311.filter(c,e)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (not e or c:IsCanBeEffectTarget(e))
end
-- 过滤条件：检测第一张送去墓地的「忍者」怪兽，并确保存在可配合的「忍法」卡，同时处理装备卡等重叠情况
function c90247311.costfilter(c,rg,dg)
	if not (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b)) then return false end
	local a=0
	if dg:IsContains(c) then a=1 end
	if c:GetEquipCount()==0 then return rg:IsExists(c90247311.costfilter2,1,c,a,dg) end
	local eg=c:GetEquipGroup()
	local tc=eg:GetFirst()
	while tc do
		if dg:IsContains(tc) then a=a+1 end
		tc=eg:GetNext()
	end
	return rg:IsExists(c90247311.costfilter2,1,c,a,dg)
end
-- 过滤条件：检测第二张送去墓地的「忍法」卡，并确保在扣除送墓卡片后场上仍有足够数量的魔法·陷阱卡作为破坏对象
function c90247311.costfilter2(c,a,dg)
	if dg:IsContains(c) then a=a+1 end
	return c:IsSetCard(0x61) and #dg-a>=1
end
-- 效果目标：处理发动时的代价支付（送去墓地）以及选择场上最多2张魔法·陷阱卡作为效果对象
function c90247311.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c90247311.filter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 获取手牌及自己场上表侧表示的、满足送墓条件的「忍者」怪兽和「忍法」卡组
			local rg=Duel.GetMatchingGroup(c90247311.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
			-- 获取场上所有可以作为效果对象的魔法·陷阱卡组
			local dg=Duel.GetMatchingGroup(c90247311.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
			return rg:IsExists(c90247311.costfilter,1,nil,rg,dg)
		else
			-- 非发动时（如其他卡的效果复制此效果时）检测场上是否存在至少1张魔法·陷阱卡作为对象
			return Duel.IsExistingTarget(c90247311.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 获取手牌及自己场上表侧表示的、满足送墓条件的「忍者」怪兽和「忍法」卡组
		local rg=Duel.GetMatchingGroup(c90247311.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
		-- 获取场上所有可以作为效果对象的魔法·陷阱卡组
		local dg=Duel.GetMatchingGroup(c90247311.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg1=rg:FilterSelect(tp,c90247311.costfilter,1,1,nil,rg,dg)
		local sc=sg1:GetFirst()
		local a=0
		if dg:IsContains(sc) then a=1 end
		if sc:GetEquipCount()>0 then
			local eqg=sc:GetEquipGroup()
			local tc=eqg:GetFirst()
			while tc do
				if dg:IsContains(tc) then a=a+1 end
				tc=eqg:GetNext()
			end
		end
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg2=rg:FilterSelect(tp,c90247311.costfilter2,1,1,sc,a,dg)
		sg1:Merge(sg2)
		-- 将选定的「忍者」怪兽和「忍法」卡作为发动代价送去墓地
		Duel.SendtoGrave(sg1,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1到2张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c90247311.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置连锁信息，表明此效果的操作是破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果处理：破坏仍存在于场上的对象卡片
function c90247311.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果关联的对象卡片破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
