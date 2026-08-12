--ドラグニティナイト－アラドヴァル
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方把怪兽的效果发动时，从自己墓地把1只「龙骑兵团」怪兽除外才能发动。那个发动无效并除外。
-- ②：这张卡战斗破坏对方怪兽的伤害计算后才能发动。那只对方怪兽除外。
-- ③：同调召唤的这张卡被对方破坏的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
function c88234821.initial_effect(c)
	-- 为卡片添加同调召唤手续：需要「龙骑兵团」调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方把怪兽的效果发动时，从自己墓地把1只「龙骑兵团」怪兽除外才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88234821,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88234821)
	e1:SetCondition(c88234821.negcon)
	e1:SetCost(c88234821.negcost)
	-- 设置效果的目标处理函数为通用的无效并除外处理函数aux.nbtg
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c88234821.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的伤害计算后才能发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88234821,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88234822)
	e2:SetCondition(c88234821.rmcon)
	e2:SetTarget(c88234821.rmtg)
	e2:SetOperation(c88234821.rmop)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡被对方破坏的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,88234823)
	e3:SetCondition(c88234821.descon)
	e3:SetTarget(c88234821.destg)
	e3:SetOperation(c88234821.desop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：用于筛选自己墓地中可以作为Cost除外的「龙骑兵团」怪兽
function c88234821.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x29) and c:IsAbleToRemoveAsCost()
end
-- 定义效果①的发动条件检测函数
function c88234821.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测是否为对方发动的怪兽效果，且此卡未被战斗破坏，且该发动可以被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 定义效果①的Cost支付处理函数
function c88234821.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测自己墓地是否存在至少1只满足过滤条件的「龙骑兵团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88234821.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地中选择1只满足过滤条件的「龙骑兵团」怪兽
	local g=Duel.SelectMatchingCard(tp,c88234821.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外以支付发动Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义效果①的效果处理函数
function c88234821.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，并确认发动效果的卡片是否仍与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡片除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义效果②的发动条件检测函数：检测此卡是否战斗破坏了对方怪兽并进行标记
function c88234821.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- 定义效果②的目标选择与检测函数
function c88234821.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc:IsAbleToRemove() end
	-- 设置操作信息：在效果处理时将除外1张被战斗破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 定义效果②的效果处理函数
function c88234821.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将该被战斗破坏的对方怪兽除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义效果③的发动条件检测函数：检测同调召唤的此卡是否被对方破坏
function c88234821.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义效果③的目标选择与检测函数
function c88234821.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：在效果处理时将破坏对方场上所有的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 定义效果③的效果处理函数
function c88234821.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 将获取到的对方场上的魔法·陷阱卡全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
