--古聖戴サウラヴィス
-- 效果：
-- 「精灵的祝福」降临
-- ①：自己场上的怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
-- ②：对方把怪兽特殊召唤之际，让场上的这张卡回到手卡才能发动。那次特殊召唤无效，那些怪兽除外。
function c4810828.initial_effect(c)
	-- 将「精灵的祝福」（37626500）加入卡片记述的相关卡片列表中
	aux.AddCodeList(c,37626500)
	c:EnableReviveLimit()
	-- ①：自己场上的怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
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
	-- ②：对方把怪兽特殊召唤之际，让场上的这张卡回到手卡才能发动。那次特殊召唤无效，那些怪兽除外。
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
-- 过滤自己场上的怪兽
function c4810828.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 无效发动效果的发动条件判断
function c4810828.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 获取当前发动效果的对象卡片
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象卡中是否存在自己场上的怪兽，且该发动的效果可以被无效
	return g and g:IsExists(c4810828.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 无效发动效果的发动代价（丢弃自身）
function c4810828.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 无效发动效果的靶向与发动检测
function c4810828.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效发动效果的效果处理
function c4810828.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标效果的发动无效
	Duel.NegateActivation(ev)
end
-- 无效特殊召唤效果的发动条件判断
function c4810828.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是对方进行特殊召唤，且不在连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 无效特殊召唤效果的发动代价（此卡回到手卡）
function c4810828.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	-- 使场上的此卡回到持有者手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
-- 无效特殊召唤效果的靶向与发动检测
function c4810828.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡片除外
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	-- 设置无效特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置除外特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
end
-- 无效特殊召唤效果的效果处理
function c4810828.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方怪兽的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 将特殊召唤被无效的怪兽表侧表示除外
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
