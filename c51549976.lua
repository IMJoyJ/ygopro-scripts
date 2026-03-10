--ファイナル・インゼクション
-- 效果：
-- 把自己场上表侧表示存在的5张名字带有「甲虫装机」的卡送去墓地才能发动。对方场上的卡全部破坏。对方在这个回合的战斗阶段中不能把手卡·墓地发动的效果怪兽的效果发动。
function c51549976.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的5张名字带有「甲虫装机」的卡送去墓地才能发动。对方场上的卡全部破坏。对方在这个回合的战斗阶段中不能把手卡·墓地发动的效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c51549976.cost)
	e1:SetTarget(c51549976.target)
	e1:SetOperation(c51549976.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在满足条件的「甲虫装机」怪兽（表侧表示、名字带有甲虫装机、可以作为cost送去墓地）
function c51549976.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x56) and c:IsAbleToGraveAsCost()
end
-- 效果处理时点，检查是否满足cost条件并选择5张符合条件的卡送去墓地
function c51549976.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上是否存在至少5张名字带有「甲虫装机」且表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51549976.cfilter,tp,LOCATION_ONFIELD,0,5,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的5张卡
	local g=Duel.SelectMatchingCard(tp,c51549976.cfilter,tp,LOCATION_ONFIELD,0,5,5,nil)
	-- 将选中的卡送去墓地作为发动cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的目标，准备破坏对方场上的所有卡
function c51549976.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将要破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时点，执行破坏对方场上所有卡并设置对方不能发动手卡/墓地怪兽效果的限制
function c51549976.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
	-- 效果原文内容：把自己场上表侧表示存在的5张名字带有「甲虫装机」的卡送去墓地才能发动。对方场上的卡全部破坏。对方在这个回合的战斗阶段中不能把手卡·墓地发动的效果怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c51549976.actcon)
	e1:SetValue(c51549976.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将设置好的效果注册给玩家，使其生效到结束阶段
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前是否处于战斗阶段（主要阶段1之后、主要阶段2之前）
function c51549976.actcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>PHASE_MAIN1 and ph<PHASE_MAIN2
end
-- 限制条件函数，判断被禁止发动的效果是否为手卡或墓地的效果怪兽
function c51549976.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_HAND+LOCATION_GRAVE)
end
