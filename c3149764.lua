--ツタン仮面
-- 效果：
-- 场上表侧表示存在的1只不死族怪兽为对象的魔法·陷阱卡的发动无效并破坏。
function c3149764.initial_effect(c)
	-- 效果原文：场上表侧表示存在的1只不死族怪兽为对象的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3149764.condition)
	e1:SetTarget(c3149764.target)
	e1:SetOperation(c3149764.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：位置在主要怪兽区且表侧表示且种族为不死族的怪兽
function c3149764.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 效果作用：判断连锁是否为魔法·陷阱卡的发动且对象为1只不死族怪兽且该连锁可被无效
function c3149764.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 效果作用：获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 效果作用：判断对象卡片组存在且数量为1且第一张卡满足cfilter条件且当前连锁可被无效
	return tg and tg:GetCount()==1 and c3149764.cfilter(tg:GetFirst()) and Duel.IsChainNegatable(ev)
end
-- 效果作用：设置连锁处理信息，将使发动无效和破坏效果加入处理列表
function c3149764.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁处理信息，将使发动无效效果加入处理列表
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置连锁处理信息，将使破坏效果加入处理列表
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行效果处理，使连锁发动无效并破坏对象卡片
function c3149764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使连锁发动无效且对象卡片与效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：以效果原因破坏对象卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
