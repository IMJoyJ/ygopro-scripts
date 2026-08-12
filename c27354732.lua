--魔導獣 キングジャッカル
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组把「魔导兽 胡狼王」以外的1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
-- ②：1回合1次，对方怪兽的效果发动时，把自己场上2个魔力指示物取除才能发动。那个发动无效并破坏。
function c27354732.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（使其可以进行灵摆卡的发动与灵摆召唤）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组把「魔导兽 胡狼王」以外的1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27354732,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,27354732)
	e1:SetCondition(c27354732.spcon)
	e1:SetTarget(c27354732.sptg)
	e1:SetOperation(c27354732.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。（此效果用于记录连锁发生时这张卡在场上存在）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在，为后续放置魔力指示物的永续处理提供依据
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c27354732.acop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，对方怪兽的效果发动时，把自己场上2个魔力指示物取除才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27354732,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c27354732.condition)
	e4:SetCost(c27354732.cost)
	e4:SetTarget(c27354732.target)
	e4:SetOperation(c27354732.operation)
	c:RegisterEffect(e4)
end
c27354732.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果的发动条件函数：检查另一边的自己灵摆区域没有卡存在
function c27354732.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 另一边的自己的灵摆区域（除这张卡外）不存在任何卡时才能发动
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 特殊召唤对象过滤函数：筛选额外卡组中表侧表示的「魔导兽 胡狼王」以外的「魔导兽」灵摆怪兽
function c27354732.spfilter(c,e,tp)
	return c:IsSetCard(0x10d) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsCode(27354732)
		-- 并且该怪兽可以被特殊召唤、且自己场上存在能让额外卡组怪兽出场的空格
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 灵摆效果的目标函数：检查这张卡可以被破坏，并且额外卡组存在满足条件的可特殊召唤怪兽
function c27354732.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查自己的额外卡组中存在至少1只满足spfilter条件的「魔导兽」灵摆怪兽
		and Duel.IsExistingMatchingCard(c27354732.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：此连锁确定要破坏的卡为这张卡自身（灵摆区域的这张卡）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：此连锁预计从自己的额外卡组特殊召唤1只怪兽（对象在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果的处理：先破坏这张卡，再从额外卡组选1只「魔导兽」灵摆怪兽特殊召唤
function c27354732.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与该效果关联（未被离场等），则以效果破坏这张卡，破坏成功才继续处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的额外卡组选择1只满足条件的「魔导兽」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c27354732.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 把选出的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 永续处理：当自己或对方把魔法卡发动的连锁处理开始时，若这张卡在场上存在，则给这张卡放置2个魔力指示物
function c27354732.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 诱发即时效果的发动条件函数：检查是否为对方怪兽的效果发动
function c27354732.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发动条件：发动者为对方、发动的效果为怪兽效果、这张卡未被战斗破坏、且该连锁的发动可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 发动代价函数：把自己场上2个魔力指示物取除
function c27354732.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查能否以代价为由移除自己场上2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 把自己场上2个魔力指示物取除作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 目标函数：设置使那个发动无效的操作信息，若发动的效果的卡可以被破坏则同时设置破坏的操作信息
function c27354732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：此连锁要使作为发动对象的连锁（eg）的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的卡可以被破坏且仍与效果关联，则设置操作信息：破坏那张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使对方怪兽的效果发动无效，无效成功的场合把那张卡破坏
function c27354732.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效，且无效成功后那张卡仍与效果关联时继续处理
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 把发动被无效的对方的怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
