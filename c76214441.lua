--ライフ・コーディネイター
-- 效果：
-- 对方把持有「给与基本分伤害的效果」的卡发动时，可以从手卡把这张卡丢弃让那个发动无效并破坏。
function c76214441.initial_effect(c)
	-- 对方把持有「给与基本分伤害的效果」的卡发动时，可以从手卡把这张卡丢弃让那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76214441,0))  --"效果无效"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76214441.discon)
	e1:SetCost(c76214441.discost)
	e1:SetTarget(c76214441.distg)
	e1:SetOperation(c76214441.disop)
	c:RegisterEffect(e1)
end
-- 条件判断：检查对方发动的效果是否包含给与基本分伤害的效果（包括因效果变为伤害的回复效果），且该发动可以被无效
function c76214441.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果是自己发动的效果、或者是已在场上的魔法·陷阱卡的效果发动（非卡片发动）、或者该连锁无法被无效，则不满足条件
	if ep==tp or (re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)) or not Duel.IsChainNegatable(ev) then return false end
	-- 获取该连锁是否包含给与伤害的操作信息
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex then return true end
	-- 获取该连锁是否包含回复生命值的操作信息
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	-- 若存在回复效果，且目标玩家不是双方，则检查该目标玩家是否受到「回复变伤害」效果的影响
	return ex and ((cp~=PLAYER_ALL and Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_RECOVER)) or
		-- 若回复目标为双方，则检查任意一方玩家是否受到「回复变伤害」效果的影响
		(cp==PLAYER_ALL and (Duel.IsPlayerAffectedByEffect(0,EFFECT_REVERSE_RECOVER) or Duel.IsPlayerAffectedByEffect(1,EFFECT_REVERSE_RECOVER))))
end
-- 代价处理：检查并从手卡丢弃这张卡
function c76214441.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 目标确认：设置无效与破坏的操作信息
function c76214441.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若目标卡片可被破坏且仍与效果关联，设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function c76214441.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且目标卡片仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
