--遺言の仮面
-- 效果：
-- ①：这张卡回到持有者卡组。
-- ②：这张卡用「假面魔兽 死亡护法师」的效果装备中的场合，得到装备怪兽的控制权。
function c22610082.initial_effect(c)
	-- ①：这张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c22610082.cost)
	e1:SetTarget(c22610082.target)
	e1:SetOperation(c22610082.activate)
	c:RegisterEffect(e1)
end
-- 设置效果标签为1以标记成本已支付
function c22610082.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 检查是否满足将此卡送入卡组的条件并设置操作信息
function c22610082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return e:GetHandler():IsAbleToDeck()
	end
	e:SetLabel(0)
	-- 设置连锁操作信息，表明此效果将把卡片送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行效果，将此卡送入卡组
function c22610082.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以效果原因送入卡组底部并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
