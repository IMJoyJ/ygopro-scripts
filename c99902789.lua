--チャウチャウちゃん
-- 效果：
-- 和对方怪兽进行战斗的自己怪兽的攻击宣言时对方把通常陷阱卡发动时，把这张卡从手卡丢弃才能发动。那个发动无效并破坏。
function c99902789.initial_effect(c)
	-- 把这张卡从手卡丢弃才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99902789,0))  --"陷阱无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c99902789.discon)
	e1:SetCost(c99902789.discost)
	e1:SetTarget(c99902789.distg)
	e1:SetOperation(c99902789.disop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己怪兽攻击宣言时，对方发动通常陷阱卡且该发动可被无效，同时满足攻击对象为对方怪兽。
function c99902789.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前时点为攻击宣言，攻击怪兽为自己控制，且存在攻击对象（与对方怪兽战斗）。
	return Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and Duel.GetAttacker():IsControler(tp) and Duel.GetAttackTarget()~=nil
		-- 检查发动陷阱卡的玩家为对方，且该卡为通常陷阱卡的发动（非永续/反击等效果发动），并且该连锁效果能被无效。
		and ep~=tp and re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 代价条件与支付：从手牌丢弃这张卡作为发动代价；chk==0时仅检查能否丢弃。
function c99902789.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手牌送去墓地，作为发动代价（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果发动时登记无效并破坏的操作信息；若对象可破坏，则追加破坏的预设定信息。
function c99902789.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的对方通常陷阱卡作为无效对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将该通常陷阱卡作为破坏对象（若其可破坏且仍关联）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效该通常陷阱卡的发动，并破坏那张卡。
function c99902789.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定无效发动是否成功，且该卡仍然存在于应破坏的区域内，才继续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏那张通常陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
