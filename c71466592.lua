--魔力吸収球体
-- 效果：
-- 对方把魔法卡发动时，可以把自己场上表侧表示存在的这张卡解放，那个发动无效并破坏。这个效果在对方回合才能发动。
function c71466592.initial_effect(c)
	-- 对方把魔法卡发动时，可以把自己场上表侧表示存在的这张卡解放，那个发动无效并破坏。这个效果在对方回合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71466592,0))  --"魔法的发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c71466592.condition)
	e1:SetCost(c71466592.cost)
	e1:SetTarget(c71466592.target)
	e1:SetOperation(c71466592.activate)
	c:RegisterEffect(e1)
end
-- 发动无效并破坏效果的发动条件判定
function c71466592.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		-- 判断连锁效果是否为魔法卡的发动且能被无效
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 判断当前是否为对方回合
		and Duel.GetTurnPlayer()~=tp
end
-- 解放自身作为发动代价
function c71466592.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 发动无效并破坏效果的目标判定与操作信息注册
function c71466592.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 发动无效并破坏效果处理
function c71466592.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使魔法卡的发动无效并判断该卡是否与效果有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
