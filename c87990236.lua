--魅惑の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「堕天使」怪兽送去墓地才能发动。选对方场上1只表侧表示怪兽直到结束阶段得到控制权。
function c87990236.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把1只「堕天使」怪兽送去墓地才能发动。选对方场上1只表侧表示怪兽直到结束阶段得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87990236+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c87990236.cost)
	e1:SetTarget(c87990236.target)
	e1:SetOperation(c87990236.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡或自己场上表侧表示的「堕天使」怪兽，且该卡送去墓地后自己场上有空余的怪兽区域可以容纳夺取控制权的怪兽
function c87990236.costfilter(c,tp)
	return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 限制卡片必须在手卡或场上表侧表示，且该卡送去墓地后，自己场上必须有可用的怪兽区域来放置夺取控制权的怪兽
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 发动代价（Cost）处理：从手卡或自己场上将1只「堕天使」怪兽送去墓地
function c87990236.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- Cost的chk==0阶段：检查手卡或场上是否存在满足送墓条件且能腾出怪兽区域的「堕天使」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87990236.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手卡或场上表侧表示的「堕天使」怪兽
	local g=Duel.SelectMatchingCard(tp,c87990236.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：对方场上表侧表示且可以改变控制权的怪兽
function c87990236.filter(c,check)
	return c:IsControlerCanBeChanged(check) and c:IsFaceup()
end
-- 效果发动时的目标确认（Target）处理
function c87990236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check=e:GetLabel()==100
		e:SetLabel(0)
		-- 检查对方场上是否存在可以改变控制权的表侧表示怪兽
		return Duel.IsExistingMatchingCard(c87990236.filter,tp,0,LOCATION_MZONE,1,nil,check)
	end
	-- 设置效果处理信息：包含改变控制权分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 过滤条件：对方场上表侧表示且可以改变控制权的怪兽（用于效果处理时）
function c87990236.filter2(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
-- 效果处理（Operation）阶段：选择对方场上1只表侧表示怪兽，直到结束阶段得到控制权
function c87990236.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1只表侧表示且可以改变控制权的怪兽
	local g=Duel.SelectMatchingCard(tp,c87990236.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家直到结束阶段为止得到目标怪兽的控制权
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
