--ナチュル・ガイアストライオ
-- 效果：
-- 地属性同调怪兽×2
-- ①：只以场上的卡1张为对象的魔法·陷阱·怪兽的效果发动时，把1张手卡送去墓地才能发动。那个发动无效并破坏。
function c90555947.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2个满足特定过滤条件的素材
	aux.AddFusionProcFunRep(c,c90555947.ffilter,2,true)
	-- ①：只以场上的卡1张为对象的魔法·陷阱·怪兽的效果发动时，把1张手卡送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90555947,0))  --"无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c90555947.discon)
	e1:SetCost(c90555947.discost)
	e1:SetTarget(c90555947.distg)
	e1:SetOperation(c90555947.disop)
	c:RegisterEffect(e1)
end
c90555947.material_type=TYPE_SYNCHRO
-- 过滤函数：地属性且是同调怪兽
function c90555947.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 效果发动条件判断：自身未战斗破坏，且连锁的效果是只以场上1张卡为对象的取对象效果，且该发动可以被无效
function c90555947.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡片组数量是否为1、该卡是否在场上，且该连锁的发动能否被无效
	return tg and tg:GetCount()==1 and tg:GetFirst():IsOnField() and Duel.IsChainNegatable(ev)
end
-- 效果发动代价：将1张手牌送去墓地
function c90555947.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手牌中是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1张卡作为代价送去墓地
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 效果发动目标：设置无效发动和破坏的操作信息
function c90555947.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示该效果包含破坏的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效该发动并将其破坏
function c90555947.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在效果处理时仍与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
