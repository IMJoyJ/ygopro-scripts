--コアキメイル・パワーハンド
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1张通常陷阱卡给对方观看。或者都不进行让这张卡破坏。这张卡和光属性或者暗属性怪兽进行战斗的场合，只在战斗阶段内那只怪兽的效果无效化。
function c19642889.initial_effect(c)
	-- 记录此卡具有「核成兽的钢核」这张卡的卡名
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
-- 判断是否为当前回合玩家触发效果
function c19642889.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家触发效果
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为cost送去墓地的「核成兽的钢核」
function c19642889.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的通常陷阱卡
function c19642889.cfilter2(c)
	return c:GetType()==TYPE_TRAP and not c:IsPublic()
end
-- 处理结束阶段效果选择：选择送去墓地、给对方确认陷阱或破坏此卡
function c19642889.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c19642889.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取满足条件的通常陷阱卡组
	local g2=Duel.GetMatchingGroup(c19642889.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当手卡同时有「核成兽的钢核」和通常陷阱时，选择操作选项
		select=Duel.SelectOption(tp,aux.Stringid(19642889,0),aux.Stringid(19642889,1),aux.Stringid(19642889,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张通常陷阱给对方观看/破坏「核成电钻手」"
	elseif g1:GetCount()>0 then
		-- 当手卡只有「核成兽的钢核」时，选择操作选项
		select=Duel.SelectOption(tp,aux.Stringid(19642889,0),aux.Stringid(19642889,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成电钻手」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当手卡只有通常陷阱时，选择操作选项
		select=Duel.SelectOption(tp,aux.Stringid(19642889,1),aux.Stringid(19642889,2))+1  --"选择一张通常陷阱给对方观看/破坏「核成电钻手」"
	else
		-- 当手卡无符合条件卡时，选择破坏此卡
		select=Duel.SelectOption(tp,aux.Stringid(19642889,2))  --"破坏「核成电钻手」"
		select=2
	end
	if select==0 then
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 确认对方查看所选陷阱卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏此卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 当此卡攻击或被攻击时，若对方怪兽为光或暗属性则标记其效果无效
function c19642889.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) then
		tc:RegisterFlagEffect(19642889,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 判断目标怪兽是否被标记为效果无效
function c19642889.distg(e,c)
	return c:GetFlagEffect(19642889)~=0
end
