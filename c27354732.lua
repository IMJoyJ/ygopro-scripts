--魔導獣 キングジャッカル
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组把「魔导兽 胡狼王」以外的1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
-- ②：1回合1次，对方怪兽的效果发动时，把自己场上2个魔力指示物取除才能发动。那个发动无效并破坏。
function c27354732.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组把「魔导兽 胡狼王」以外的1只表侧表示的「魔导兽」灵摆怪兽特殊召唤。
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
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方怪兽的效果发动时，把自己场上2个魔力指示物取除才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c27354732.acop)
	c:RegisterEffect(e3)
	-- 将目标怪兽特殊召唤
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
-- 判断另一边的自己的灵摆区域是否没有卡存在
function c27354732.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 另一边的自己的灵摆区域没有卡存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤满足条件的额外卡组中的魔导兽灵摆怪兽
function c27354732.spfilter(c,e,tp)
	return c:IsSetCard(0x10d) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsCode(27354732)
		-- 满足特殊召唤条件且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置连锁处理时的判定条件
function c27354732.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查是否存在满足条件的额外卡组怪兽
		and Duel.IsExistingMatchingCard(c27354732.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行灵摆效果的处理流程
function c27354732.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否可以被破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的额外卡组怪兽
		local g=Duel.SelectMatchingCard(tp,c27354732.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 当魔法卡发动时为卡片添加魔力指示物
function c27354732.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 判断是否可以发动无效效果
function c27354732.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方怪兽的效果发动且不是在战斗阶段被破坏
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置无效效果的消耗
function c27354732.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 移除2个魔力指示物作为消耗
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 设置无效效果的目标信息
function c27354732.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效效果并破坏目标
function c27354732.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以无效发动并破坏目标
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
