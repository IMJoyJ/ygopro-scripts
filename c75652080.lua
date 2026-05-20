--ダブル・サイクロン
-- 效果：
-- ①：以自己场上1张魔法·陷阱卡和对方场上1张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c75652080.initial_effect(c)
	-- ①：以自己场上1张魔法·陷阱卡和对方场上1张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c75652080.target)
	e1:SetOperation(c75652080.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上的魔法·陷阱卡
function c75652080.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的对象选择与合法性检查
function c75652080.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1张可以成为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c75652080.filter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己场上是否存在至少1张除这张卡以外可以成为对象的魔法·陷阱卡
		and Duel.IsExistingTarget(c75652080.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张魔法·陷阱卡作为效果对象
	local g1=Duel.SelectTarget(tp,c75652080.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象
	local g2=Duel.SelectTarget(tp,c75652080.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理：破坏作为对象的卡
function c75652080.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍存在于场上且与效果相关的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
