--星遺物への抵抗
-- 效果：
-- ①：以最多有场上的互相连接状态的怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
function c58374719.initial_effect(c)
	-- ①：以最多有场上的互相连接状态的怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58374719.target)
	e1:SetOperation(c58374719.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否处于互相连接状态
function c58374719.cfilter(c)
	return c:GetMutualLinkedGroupCount()>0
end
-- 效果发动时的对象选择与合法性检测
function c58374719.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 发动条件检测：自己场上是否存在至少1只处于互相连接状态的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58374719.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且场上是否存在至少1张可以作为对象的魔法·陷阱卡
		and Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 计算自己场上处于互相连接状态的怪兽数量，作为可选对象的最大数量
	local ct=Duel.GetMatchingGroupCount(c58374719.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1到ct张场上的魔法·陷阱卡作为效果对象
	local sg=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理：破坏作为对象的卡
function c58374719.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
