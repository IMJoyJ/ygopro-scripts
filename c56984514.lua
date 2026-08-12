--永久に輝けし黄金郷
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「黄金国巫妖」怪兽存在，怪兽的效果·魔法·陷阱卡发动时，把自己场上1只不死族怪兽解放才能发动。那个发动无效并破坏。
function c56984514.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「黄金国巫妖」怪兽存在，怪兽的效果·魔法·陷阱卡发动时，把自己场上1只不死族怪兽解放才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,56984514+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56984514.condition)
	e1:SetCost(c56984514.cost)
	e1:SetTarget(c56984514.target)
	e1:SetOperation(c56984514.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「黄金国巫妖」怪兽
function c56984514.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 发动条件：怪兽的效果·魔法·陷阱卡发动时，且自己场上有「黄金国巫妖」怪兽存在
function c56984514.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的发动是否为怪兽效果、魔法或陷阱卡的发动，且该发动可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「黄金国巫妖」怪兽
		and Duel.IsExistingMatchingCard(c56984514.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤自己场上可解放的不死族怪兽
function c56984514.cfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价：解放自己场上1只不死族怪兽
function c56984514.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否存在可解放的不死族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c56984514.cfilter,1,nil,tp) end
	-- 选择自己场上1只可解放的不死族怪兽
	local sg=Duel.SelectReleaseGroup(tp,c56984514.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 设置效果的目标与操作信息
function c56984514.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c56984514.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡与该效果有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
