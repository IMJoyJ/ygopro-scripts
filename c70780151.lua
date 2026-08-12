--メンタルスフィア・デーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
-- ②：只以念动力族怪兽1只为对象的魔法·陷阱卡发动时，支付1000基本分才能发动。那个发动无效并破坏。
function c70780151.initial_effect(c)
	-- 为这张卡添加同调召唤手续（调整+调整以外的怪兽1只以上）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70780151,0))  --"基本分回复破坏怪兽的原本攻击力的数值"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c70780151.condition)
	e1:SetTarget(c70780151.target)
	e1:SetOperation(c70780151.operation)
	c:RegisterEffect(e1)
	-- ②：只以念动力族怪兽1只为对象的魔法·陷阱卡发动时，支付1000基本分才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70780151,1))  --"以1只念动力族怪兽为对象的魔法或者陷阱卡的发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c70780151.discon)
	e2:SetCost(c70780151.discost)
	e2:SetTarget(c70780151.distg)
	e2:SetOperation(c70780151.disop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否因战斗关系存在，且被战斗破坏的怪兽是否已送去墓地且原本是怪兽卡
function c70780151.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果1的发动准备，获取被破坏怪兽的攻击力，并设置回复基本分的操作信息
function c70780151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置回复基本分的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为被破坏怪兽的攻击力
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为回复自己对应数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
end
-- 效果1的处理，获取目标玩家和回复数值，执行回复基本分的操作
function c70780151.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 检查发动的魔法·陷阱卡是否只以1只念动力族怪兽为对象，且该发动可以被无效
function c70780151.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取触发连锁的效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or tg:GetCount()~=1 or not tg:GetFirst():IsRace(RACE_PSYCHO) then return false end
	-- 检查触发的效果是否为魔法·陷阱卡的发动，且该发动可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果2的代价处理，检查并支付1000基本分
function c70780151.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 效果2的发动准备，设置无效发动和破坏卡片的操作信息
function c70780151.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果2的处理，尝试无效该魔法·陷阱卡的发动，若成功则将其破坏
function c70780151.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 尝试使该魔法·陷阱卡的发动无效，并检查该卡是否仍与自身效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果破坏该魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
