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
-- 代价处理：该效果无实际代价，仅将标签置1，用于标记已经通过发动时的代价检查。
function c22610082.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 发动目标判定：检查是否已满足发动前提（标签为1），然后重置标签；随后确认这张卡本身能否返回卡组，若可以则登记回卡组的操作信息。
function c22610082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return e:GetHandler():IsAbleToDeck()
	end
	e:SetLabel(0)
	-- 设置操作信息：本次处理属于“返回卡组”的分类，处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与本次发动相关，则将其返回持有者卡组。
function c22610082.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以效果原因返回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
