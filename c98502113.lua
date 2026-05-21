--超魔導剣士－ブラック・パラディン
-- 效果：
-- 「黑魔术师」＋「破坏之剑士」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升双方的场上·墓地的龙族怪兽数量×500。
-- ②：魔法卡发动时，丢弃1张手卡才能发动。这张卡在怪兽区域表侧表示存在的场合，那个发动无效并破坏。
function c98502113.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「黑魔术师」与「破坏之剑士」作为融合素材，并允许使用融合代替素材
	aux.AddFusionProcCode2(c,46986414,78193831,true,true)
	-- ②：魔法卡发动时，丢弃1张手卡才能发动。这张卡在怪兽区域表侧表示存在的场合，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98502113,0))  --"魔法发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c98502113.discon)
	e1:SetCost(c98502113.discost)
	e1:SetTarget(c98502113.distg)
	e1:SetOperation(c98502113.disop)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升双方的场上·墓地的龙族怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c98502113.val)
	c:RegisterEffect(e2)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤限制为仅能通过融合召唤进行特殊召唤
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
-- 计算攻击力上升值的函数，返回双方场上及墓地的龙族怪兽数量乘以500
function c98502113.val(e,c)
	-- 获取双方场上和墓地中满足过滤条件的卡片数量并乘以500
	return Duel.GetMatchingGroupCount(c98502113.filter,0,0x14,0x14,nil)*500
end
-- 过滤条件：双方场上表侧表示存在或在墓地存在的龙族怪兽
function c98502113.filter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 魔法发动无效效果的发动条件判断函数
function c98502113.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查发动的卡是否为魔法卡的发动，且该连锁的发动可以被无效
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 魔法发动无效效果的发动代价处理函数
function c98502113.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 魔法发动无效效果的目标确认与操作信息设置函数
function c98502113.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将要破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 魔法发动无效效果的效果处理函数
function c98502113.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 尝试无效该连锁的发动，若成功且该卡仍与该效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
