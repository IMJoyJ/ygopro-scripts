--背徳の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）把1只「堕天使」怪兽送去墓地才能发动。场上1张卡破坏。
function c50501121.initial_effect(c)
	-- 效果原文内容：①：从自己的手卡·场上（表侧表示）把1只「堕天使」怪兽送去墓地才能发动。场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50501121+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c50501121.cost)
	e1:SetTarget(c50501121.target)
	e1:SetOperation(c50501121.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义了支付代价时的过滤条件，用于筛选满足条件的「堕天使」怪兽
function c50501121.costfilter(c,ec)
	return c:IsSetCard(0xef)
		and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToGraveAsCost()
		-- 规则层面作用：检查所选的怪兽是否能作为代价并满足后续破坏效果的条件
		and Duel.IsExistingMatchingCard(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- 规则层面作用：处理发动效果时的支付代价步骤，选择并送入墓地一张符合条件的「堕天使」怪兽
function c50501121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面作用：判断是否存在满足条件的「堕天使」怪兽用于支付代价
	if chk==0 then return Duel.IsExistingMatchingCard(c50501121.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,c) end
	-- 规则层面作用：向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：选择满足条件的「堕天使」怪兽作为支付代价
	local g=Duel.SelectMatchingCard(tp,c50501121.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,c)
	-- 规则层面作用：将选中的怪兽送入墓地作为发动效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 规则层面作用：设置发动效果的目标，确定要破坏的场上卡
function c50501121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 规则层面作用：获取场上所有可被选择破坏的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	if chk==0 then return g:GetCount()>0 end
	-- 规则层面作用：设置操作信息，表明该效果属于破坏类别并指定目标数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：处理效果发动后的实际破坏行为，选择并破坏一张场上卡
function c50501121.activate(e,tp,eg,ep,ev,re,r,rp)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 规则层面作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上一张卡作为破坏对象
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
	if g:GetCount()>0 then
		-- 规则层面作用：显示选中卡被破坏的动画效果
		Duel.HintSelection(g)
		-- 规则层面作用：执行破坏操作，将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
