--古聖戴サウラヴィス
-- 效果：
-- 「精灵的祝福」降临
-- ①：自己场上的怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
-- ②：对方把怪兽特殊召唤之际，让场上的这张卡回到手卡才能发动。那次特殊召唤无效，那些怪兽除外。
function c4810828.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：①：自己场上的怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4810828,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4810828.negcon)
	e1:SetCost(c4810828.negcost)
	e1:SetTarget(c4810828.negtg)
	e1:SetOperation(c4810828.negop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：对方把怪兽特殊召唤之际，让场上的这张卡回到手卡才能发动。那次特殊召唤无效，那些怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4810828,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c4810828.discon)
	e2:SetCost(c4810828.discost)
	e2:SetTarget(c4810828.distg)
	e2:SetOperation(c4810828.disop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断目标怪兽是否为己方场上怪兽
function c4810828.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 规则层面作用：判断连锁是否由对方发动且效果有对象，并且对象中有己方场上的怪兽，同时该连锁可以被无效
function c4810828.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 规则层面作用：获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 规则层面作用：检查对象卡片组中是否存在己方场上的怪兽，并确认当前连锁可被无效
	return g and g:IsExists(c4810828.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 规则层面作用：判断是否满足发动条件（丢弃手卡）
function c4810828.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 规则层面作用：将自身从手卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 规则层面作用：设置效果处理时的操作信息，准备使连锁无效
function c4810828.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置操作信息为使连锁无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 规则层面作用：执行使连锁发动无效的操作
function c4810828.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：使当前连锁发动无效
	Duel.NegateActivation(ev)
end
-- 规则层面作用：判断是否满足发动条件（回到手卡）
function c4810828.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：确认不是自己发动且当前无连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 规则层面作用：判断是否满足发动条件（将自身送回手卡）
function c4810828.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	-- 规则层面作用：将自身送回手卡作为代价
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
-- 规则层面作用：设置效果处理时的操作信息，准备使召唤无效并除外怪兽
function c4810828.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否可以除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 规则层面作用：设置操作信息为使召唤无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 规则层面作用：设置操作信息为除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- 规则层面作用：执行使召唤无效并除外目标怪兽的操作
function c4810828.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：使正在特殊召唤的怪兽召唤无效
	Duel.NegateSummon(eg)
	-- 规则层面作用：将目标怪兽除外
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
