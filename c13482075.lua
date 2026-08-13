--ヴェンデット・キマイラ
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，从自己墓地把1只不死族怪兽除外才能发动。那个发动无效并破坏。
-- ②：这张卡为仪式召唤而被解放或者除外的场合发动。对方场上的全部怪兽的攻击力·守备力下降500。
function c13482075.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，从自己墓地把1只不死族怪兽除外才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13482075,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,13482075)
	e1:SetCondition(c13482075.condition)
	e1:SetCost(c13482075.cost)
	e1:SetTarget(c13482075.target)
	e1:SetOperation(c13482075.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡为仪式召唤而被解放或者除外的场合发动。对方场上的全部怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13482075,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,13482076)
	e2:SetCondition(c13482075.atkcon)
	e2:SetOperation(c13482075.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 发动条件判定：本卡不处于战斗破坏确定状态且该连锁可以被无效；同时避免对带有无效分类的魔法·陷阱卡的发动进行连锁（防止循环）。
function c13482075.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若本卡因战斗破坏确定而无法发动，或目标连锁不能被无效，则满足条件不成立。
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若目标效果自身带有无效分类且其前一连锁是魔法·陷阱卡的发动，则本卡也不能发动。
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取该连锁中关于破坏效果的操作信息，用于判断是否满足“要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时”这一时机条件。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 代价滤卡条件：该卡是不死族怪兽且可以除外作为代价。
function c13482075.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：从自己墓地选择1只不死族怪兽除外；无法支付则不能发动。
function c13482075.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的不死族怪兽作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c13482075.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只不死族怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c13482075.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动时设定操作信息：确定要无效的连锁及需要破坏的卡；若目标卡可被破坏且仍与效果关联，则一并设定破坏对象。
function c13482075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁效果（eg）标记为要无效的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若被无效的卡可以被破坏且仍与效果关联，则将其标记为破坏对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效对应连锁的发动，并将其关联卡破坏。
function c13482075.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 当无效成功且该卡仍与效果关联时，才执行后续破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效发动的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 触发条件判定：本卡被解放或除外的原因必须是用于仪式召唤（REASON_RITUAL）。
function c13482075.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end
-- ②效果处理：对方场上的全部表侧表示怪兽的攻击力·守备力各下降500。
function c13482075.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 选取对方场上全部表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历该怪兽组，对每只表侧表示怪兽依次赋予攻守下降效果。
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽的攻击力·守备力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(-500)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
