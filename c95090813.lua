--コアキメイル・ウォーアームズ
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。1回合1次，可以选择自己墓地存在的1只等级3以下的战士族怪兽装备在这张卡上。这张卡的攻击力上升由这个效果装备的怪兽卡攻击力总和的一半。若这张卡被战斗破坏，作为代替把全部由这个效果装备的怪兽卡破坏。
function c95090813.initial_effect(c)
	-- 注册该卡片记有卡名「核成兽的钢核」的信息。
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只战士族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c95090813.mtcon)
	e1:SetOperation(c95090813.mtop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以选择自己墓地存在的1只等级3以下的战士族怪兽装备在这张卡上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95090813,3))  --"装备"
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c95090813.eqtg)
	e2:SetOperation(c95090813.eqop)
	c:RegisterEffect(e2)
end
-- 维护效果的发动条件：当前回合是控制者的回合。
function c95090813.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为该卡的控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中可以作为Cost送去墓地的「核成兽的钢核」。
function c95090813.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手牌中未公开的战士族怪兽。
function c95090813.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end
-- 结束阶段维护效果的具体处理：选择将「核成兽的钢核」送去墓地、展示战士族怪兽，或者将自身破坏。
function c95090813.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡并显示被选为对象的动画效果。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手牌中满足送墓条件的「核成兽的钢核」卡片组。
	local g1=Duel.GetMatchingGroup(c95090813.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手牌中满足展示条件的战士族怪兽卡片组。
	local g2=Duel.GetMatchingGroup(c95090813.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 玩家手牌中同时存在「核成兽的钢核」和战士族怪兽时，提供送墓、展示或破坏自身的选项。
		select=Duel.SelectOption(tp,aux.Stringid(95090813,0),aux.Stringid(95090813,1),aux.Stringid(95090813,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张战士族怪兽给对方观看/破坏「核成战甲兵」"
	elseif g1:GetCount()>0 then
		-- 玩家手牌中只有「核成兽的钢核」时，提供送墓或破坏自身的选项。
		select=Duel.SelectOption(tp,aux.Stringid(95090813,0),aux.Stringid(95090813,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成战甲兵」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 玩家手牌中只有战士族怪兽时，提供展示或破坏自身的选项，并对返回值进行偏移处理。
		select=Duel.SelectOption(tp,aux.Stringid(95090813,1),aux.Stringid(95090813,2))+1  --"选择一张战士族怪兽给对方观看/破坏「核成战甲兵」"
	else
		-- 玩家手牌中两者都没有时，强制选择破坏自身的选项。
		select=Duel.SelectOption(tp,aux.Stringid(95090813,2))  --"破坏「核成战甲兵」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡作为Cost送去墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选择的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 重新洗切手牌。
		Duel.ShuffleHand(tp)
	else
		-- 将自身作为Cost破坏。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤自己墓地中等级3以下的战士族怪兽。
function c95090813.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_WARRIOR) and not c:IsForbidden()
end
-- 装备效果的发动准备与目标选择。
function c95090813.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c95090813.filter(chkc) end
	-- 判定魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己墓地是否存在满足条件的战士族怪兽。
		and Duel.IsExistingTarget(c95090813.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c95090813.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：涉及1张卡离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的具体处理：将目标怪兽装备，并赋予攻击力上升和代破效果。
function c95090813.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 尝试将目标怪兽作为装备卡装备给此卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 装备在这张卡上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c95090813.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetAttack()
		if atk<0 then atk=0 end
		-- 这张卡的攻击力上升由这个效果装备的怪兽卡攻击力总和的一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e2)
		-- 若这张卡被战斗破坏，作为代替把全部由这个效果装备的怪兽卡破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c95090813.subval)
		tc:RegisterEffect(e3)
	end
end
-- 限制装备卡只能装备给此卡。
function c95090813.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判定破坏原因是否为战斗破坏。
function c95090813.subval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
