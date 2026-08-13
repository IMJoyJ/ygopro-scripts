--コアキメイル・パワーハンド
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1张通常陷阱卡给对方观看。或者都不进行让这张卡破坏。这张卡和光属性或者暗属性怪兽进行战斗的场合，只在战斗阶段内那只怪兽的效果无效化。
function c19642889.initial_effect(c)
	-- 将卡号36623431（核成兽的钢核）登记到本卡记载的卡名列表中，用于相关卡名检索和判定。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1张通常陷阱卡给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19642889.mtcon)
	e1:SetOperation(c19642889.mtop)
	c:RegisterEffect(e1)
	-- 这张卡和光属性或者暗属性怪兽进行战斗的场合，只在战斗阶段内那只怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c19642889.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
	-- 这张卡和光属性或者暗属性怪兽进行战斗的场合，只在战斗阶段内那只怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c19642889.distg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e5)
end
-- 结束阶段维持效果的发动条件：当前回合玩家是这张卡的控制者时，才会进行维持处理。
function c19642889.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者tp，用于限定在自己的结束阶段才发动。
	return Duel.GetTurnPlayer()==tp
end
-- 检索条件：手卡中卡号为36623431且可以作为代价送去墓地的「核成兽的钢核」。
function c19642889.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 检索条件：手卡中类型为通常陷阱且没有公开表示的卡，只有这类卡才能选择给对方观看。
function c19642889.cfilter2(c)
	return c:GetType()==TYPE_TRAP and not c:IsPublic()
end
-- 结束阶段维持效果的操作：展示本卡，检索可用的钢核和通常陷阱，根据可用情况让玩家选择送墓、展示或破坏自己。
function c19642889.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将本卡以选中动画形式展示并记录为对象，用于向双方提示正在处理维持效果。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取自己手卡中所有符合条件、可作为代价送去墓地的「核成兽的钢核」的集合。
	local g1=Duel.GetMatchingGroup(c19642889.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取自己手卡中所有符合条件、可给对方观看的通常陷阱卡的集合。
	local g2=Duel.GetMatchingGroup(c19642889.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当两种代价卡都存在时，弹出三个选项供选择：送钢核、展示陷阱、破坏本卡，并保存选择结果。
		select=Duel.SelectOption(tp,aux.Stringid(19642889,0),aux.Stringid(19642889,1),aux.Stringid(19642889,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张通常陷阱给对方观看/破坏「核成电钻手」"
	elseif g1:GetCount()>0 then
		-- 只有钢核可送时，弹出两个选项：送钢核或破坏本卡；若选择破坏，则将选项序号映射为2。
		select=Duel.SelectOption(tp,aux.Stringid(19642889,0),aux.Stringid(19642889,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成电钻手」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 只有通常陷阱可展示时，弹出两个选项：展示陷阱或破坏本卡；选择结果加1，使展示对应0、破坏对应2。
		select=Duel.SelectOption(tp,aux.Stringid(19642889,1),aux.Stringid(19642889,2))+1  --"选择一张通常陷阱给对方观看/破坏「核成电钻手」"
	else
		-- 两种代价卡都不存在时，只弹出破坏本卡的选项，并强制选择结果对应破坏。
		select=Duel.SelectOption(tp,aux.Stringid(19642889,2))  --"破坏「核成电钻手」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择一张要送去墓地的「核成兽的钢核」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的「核成兽的钢核」作为维持代价送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择一张要展示给对方确认的通常陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的通常陷阱卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示手牌后洗切自己的手卡，恢复手卡随机顺序。
		Duel.ShuffleHand(tp)
	else
		-- 当玩家没有选择任何维持代价时，将这张卡自身破坏。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 攻击宣言时，若本次战斗对象是光属性或暗属性怪兽，则给该怪兽打上标记，标记持续到战斗阶段结束，作为后续效果无效化的对象标识。
function c19642889.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) then
		tc:RegisterFlagEffect(19642889,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 判定怪兽是否带有本效果设置的标记，带标记的怪兽即为该次战斗中被无效化效果的怪兽。
function c19642889.distg(e,c)
	return c:GetFlagEffect(19642889)~=0
end
