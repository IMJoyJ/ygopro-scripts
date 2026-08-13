--ジャンクリボー
-- 效果：
-- ①：给与自己伤害的魔法·陷阱·怪兽的效果由对方发动时，把自己的手卡·场上的这张卡送去墓地才能发动。那个发动无效并破坏。
function c38491199.initial_effect(c)
	-- ①：给与自己伤害的魔法·陷阱·怪兽的效果由对方发动时，把自己的手卡·场上的这张卡送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38491199,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c38491199.negcon)
	e1:SetCost(c38491199.negcost)
	e1:SetTarget(c38491199.negtg)
	e1:SetOperation(c38491199.negop)
	c:RegisterEffect(e1)
end
-- 代价函数：判定作为发动代价能否把这张卡送去墓地；若能则执行将这张卡（手牌或场上）送入墓地。
function c38491199.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价：将废品栗子球自身以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动条件判定：仅当对方发动了会给与自己伤害的魔法·陷阱·怪兽效果、这张卡不处于战斗破坏确定状态、该连锁能被无效且满足aux.damcon1伤害条件时，本效果才能发动。
function c38491199.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件分解：ep==1-tp表示效果由对方发动；这张卡没有战斗破坏确定；Duel.IsChainNegatable(ev)确认该连锁可被无效；aux.damcon1确认存在给与自己伤害的效果。
	return ep==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 发动时目标处理：效果无选择对象；向系统登记“无效发动”的操作信息，对象为对方发动的效果所在卡（eg）；若该卡仍与效果关联且可破坏，则再登记“破坏”操作。
function c38491199.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次无效对方发动的目标确定为触发连锁的那张卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息：追加登记对同一张卡（eg）的破坏，用于处理时执行破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先尝试无效对方的效果发动；若无效成功且发动效果的那张卡仍与效果关联，则将其破坏。
function c38491199.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：无效发动成功（Duel.NegateActivation返回true），且对方效果所在卡仍与那个效果保持关联（未被离场重置联系）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因（REASON_EFFECT）破坏对方发动效果的那张卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
