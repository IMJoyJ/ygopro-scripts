--コアキメイル・グールズスレイブ
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只不死族怪兽给对方观看。或者都不进行让这张卡破坏。自己场上存在的名字带有「核成」的怪兽1只被战斗或者卡的效果破坏的场合，可以作为代替把自己墓地存在的1只名字带有「核成」的怪兽从游戏中除外。
function c5817857.initial_effect(c)
	-- 记录该卡片效果中记有「核成兽的钢核」的事实
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只不死族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c5817857.mtcon)
	e1:SetOperation(c5817857.mtop)
	c:RegisterEffect(e1)
	-- 自己场上存在的名字带有「核成」的怪兽1只被战斗或者卡的效果破坏的场合，可以作为代替把自己墓地存在的1只名字带有「核成」的怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c5817857.destg)
	e2:SetValue(1)
	e2:SetOperation(c5817857.desop)
	c:RegisterEffect(e2)
end
-- 维持效果的发动条件函数：必须是自己的回合
function c5817857.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：手牌中的「核成兽的钢核」且能作为代价送去墓地
function c5817857.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤条件：手牌中未公开的不死族怪兽
function c5817857.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and not c:IsPublic()
end
-- 维持效果的具体处理函数：选择将「核成兽的钢核」送去墓地、展示不死族怪兽或破坏自身
function c5817857.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡并显示选中动画，提示玩家该卡正在进行维持效果的处理
	Duel.HintSelection(Group.FromCards(c))
	-- 获取玩家手牌中所有满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c5817857.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取玩家手牌中所有满足条件的不死族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c5817857.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手牌中既有「核成兽的钢核」又有不死族怪兽时，让玩家在送墓、展示、破坏自身三个选项中进行选择
		select=Duel.SelectOption(tp,aux.Stringid(5817857,0),aux.Stringid(5817857,1),aux.Stringid(5817857,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张不死族怪兽给对方观看/破坏「核成食尸奴」"
	elseif g1:GetCount()>0 then
		-- 当手牌中只有「核成兽的钢核」时，让玩家在送墓、破坏自身两个选项中进行选择
		select=Duel.SelectOption(tp,aux.Stringid(5817857,0),aux.Stringid(5817857,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成食尸奴」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手牌中只有不死族怪兽时，让玩家在展示、破坏自身两个选项中进行选择，并对返回值进行偏移处理
		select=Duel.SelectOption(tp,aux.Stringid(5817857,1),aux.Stringid(5817857,2))+1  --"选择一张不死族怪兽给对方观看/破坏「核成食尸奴」"
	else
		-- 当手牌中既没有「核成兽的钢核」也没有不死族怪兽时，强制玩家选择破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(5817857,2))  --"破坏「核成食尸奴」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的卡作为维持代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的不死族怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 确认后洗切手牌
		Duel.ShuffleHand(tp)
	else
		-- 因未支付维持代价而破坏这张卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤条件：墓地中可以除外的「核成」怪兽
function c5817857.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d) and c:IsAbleToRemove()
end
-- 代替破坏效果的目标过滤与发动询问函数
function c5817857.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if eg:GetCount()~=1 then return false end
		local tc=eg:GetFirst()
		return tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x1d) and tc:IsReason(REASON_BATTLE+REASON_EFFECT) and not tc:IsReason(REASON_REPLACE)
			-- 检查自己墓地是否存在至少1只可以除外的「核成」怪兽
			and Duel.IsExistingMatchingCard(c5817857.rfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的具体处理：选择并除外墓地中的1只「核成」怪兽
function c5817857.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地存在的1只「核成」怪兽
	local g=Duel.SelectMatchingCard(tp,c5817857.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的「核成」怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
