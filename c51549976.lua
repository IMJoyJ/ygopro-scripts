--ファイナル・インゼクション
-- 效果：
-- 把自己场上表侧表示存在的5张名字带有「甲虫装机」的卡送去墓地才能发动。对方场上的卡全部破坏。对方在这个回合的战斗阶段中不能把手卡·墓地发动的效果怪兽的效果发动。
function c51549976.initial_effect(c)
	-- 把自己场上表侧表示存在的5张名字带有「甲虫装机」的卡送去墓地才能发动。对方场上的卡全部破坏。对方在这个回合的战斗阶段中不能把手卡·墓地发动的效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c51549976.cost)
	e1:SetTarget(c51549976.target)
	e1:SetOperation(c51549976.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡必须为表侧表示、属于「甲虫装机」(0x56)字段，并且可以作为代价被送入墓地。
function c51549976.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x56) and c:IsAbleToGraveAsCost()
end
-- 代价处理：先确认场上存在5张符合条件的「甲虫装机」卡，再提示玩家选择5张，并将其作为代价送入墓地。
function c51549976.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段，判断自己场上是否存在至少5张满足cfilter（表侧表示·甲虫装机·可作为代价送墓）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c51549976.cfilter,tp,LOCATION_ONFIELD,0,5,nil) end
	-- 弹出选择提示，告知玩家需要选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己场上表侧表示的「甲虫装机」卡中精确选择5张作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c51549976.cfilter,tp,LOCATION_ONFIELD,0,5,5,nil)
	-- 将选中的5张卡以代价(REASON_COST)方式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动目标设定：该效果必定能处理，预取对方场上全部卡并设置破坏的操作信息。
function c51549976.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的全部卡，作为本次效果可能破坏的对象（不取对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将操作信息设为破坏(CATEGORY_DESTROY)，目标为对方场上全部卡，数量为其总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏对方场上全部卡，并给对手附加战斗阶段内不能从手卡·墓地发动怪兽效果的限制。
function c51549976.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取对方场上全部卡，用于实际执行破坏。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因(REASON_EFFECT)将对方场上的所有卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
	-- 对方在这个回合的战斗阶段中不能把手卡·墓地发动的效果怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c51549976.actcon)
	e1:SetValue(c51549976.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新建的对方玩家限制效果注册到当前决斗中，由tp方发动并持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的条件：当前阶段必须处于战斗阶段（主要阶段1之后、主要阶段2之前）。
function c51549976.actcon(e)
	-- 获取当前阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>PHASE_MAIN1 and ph<PHASE_MAIN2
end
-- 限制的内容：试图发动的效果必须是怪兽效果，且其发动卡位于手卡或墓地；满足则不能发动。
function c51549976.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_HAND+LOCATION_GRAVE)
end
