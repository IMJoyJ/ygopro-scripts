--コアキメイル・ビートル
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只昆虫族怪兽给对方观看。或者都不进行让这张卡破坏。光属性或者暗属性怪兽表侧攻击表示特殊召唤成功时，那些怪兽变成守备表示。
function c39037517.initial_effect(c)
	-- 记录该卡具有「核成兽的钢核」这张卡的卡片密码
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只昆虫族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c39037517.mtcon)
	e1:SetOperation(c39037517.mtop)
	c:RegisterEffect(e1)
	-- 光属性或者暗属性怪兽表侧攻击表示特殊召唤成功时，那些怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39037517,3))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c39037517.target)
	e2:SetOperation(c39037517.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家
function c39037517.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可作为cost送去墓地的「核成兽的钢核」
function c39037517.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的昆虫族怪兽
function c39037517.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_INSECT) and not c:IsPublic()
end
-- 处理结束阶段效果，选择执行选项
function c39037517.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c39037517.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取满足条件的昆虫族怪兽卡片组
	local g2=Duel.GetMatchingGroup(c39037517.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 选择执行选项：送去墓地/给对方观看/破坏
		select=Duel.SelectOption(tp,aux.Stringid(39037517,0),aux.Stringid(39037517,1),aux.Stringid(39037517,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张昆虫族怪兽给对方观看/破坏「核成甲虫」"
	elseif g1:GetCount()>0 then
		-- 选择执行选项：送去墓地/破坏
		select=Duel.SelectOption(tp,aux.Stringid(39037517,0),aux.Stringid(39037517,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成甲虫」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 选择执行选项：给对方观看/破坏
		select=Duel.SelectOption(tp,aux.Stringid(39037517,1),aux.Stringid(39037517,2))+1  --"选择一张昆虫族怪兽给对方观看/破坏「核成甲虫」"
	else
		-- 选择执行选项：破坏
		select=Duel.SelectOption(tp,aux.Stringid(39037517,2))  --"破坏「核成甲虫」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	else
		-- 破坏该卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤满足条件的怪兽：表侧攻击表示且为光或暗属性
function c39037517.filter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and (not e or c:IsRelateToEffect(e))
end
-- 设置效果目标为符合条件的怪兽
function c39037517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c39037517.filter,1,nil) end
	-- 设置连锁对象为符合条件的怪兽
	Duel.SetTargetCard(eg)
end
-- 将符合条件的怪兽改变表示形式为守备表示
function c39037517.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c39037517.filter,nil,e)
	-- 将符合条件的怪兽改变表示形式为守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
