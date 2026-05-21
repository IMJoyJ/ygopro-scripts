--スモール・ワールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1只怪兽给对方观看。从卡组选种族·属性·等级·攻击力·守备力之内只有1个是和给人观看的怪兽相同的1只怪兽确认，从手卡给人观看的怪兽里侧除外。并且，再把种族·属性·等级·攻击力·守备力之内只有1个是和确认的怪兽相同的1只怪兽从卡组加入手卡，从卡组确认的怪兽里侧除外。
function c89558743.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把手卡1只怪兽给对方观看。从卡组选种族·属性·等级·攻击力·守备力之内只有1个是和给人观看的怪兽相同的1只怪兽确认，从手卡给人观看的怪兽里侧除外。并且，再把种族·属性·等级·攻击力·守备力之内只有1个是和确认的怪兽相同的1只怪兽从卡组加入手卡，从卡组确认的怪兽里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,89558743+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c89558743.target)
	e1:SetOperation(c89558743.operation)
	c:RegisterEffect(e1)
end
-- 检查两张怪兽卡在种族、属性、等级、攻击力、守备力中是否仅有1项相同
function c89558743.same_check(c,mc)
	local flag=0
	if c:GetRace()==mc:GetRace() then flag=flag+1 end
	if c:GetAttribute()==mc:GetAttribute() then flag=flag+1 end
	if c:GetLevel()==mc:GetLevel() then flag=flag+1 end
	if c:GetTextAttack()==mc:GetTextAttack() then flag=flag+1 end
	if c:GetTextDefense()==mc:GetTextDefense() then flag=flag+1 end
	return flag==1
end
-- 过滤手牌中可作为展示对象的怪兽：必须是怪兽卡、能里侧除外、未公开，且卡组中存在满足第二步过滤条件的怪兽
function c89558743.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove(tp,POS_FACEDOWN) and not c:IsPublic()
		-- 检查卡组中是否存在至少1只满足第二步过滤条件（与手牌展示怪兽仅有1项相同且能里侧除外，并能继续检索第三张怪兽）的怪兽
		and Duel.IsExistingMatchingCard(c89558743.filter2,tp,LOCATION_DECK,0,1,nil,tp,c)
end
-- 过滤卡组中作为中间媒介确认的怪兽：必须是怪兽卡、能里侧除外、与手牌展示的怪兽仅有1项相同，且卡组中存在满足第三步过滤条件的怪兽
function c89558743.filter2(c,tp,mc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove(tp,POS_FACEDOWN) and c89558743.same_check(c,mc)
		-- 检查卡组中是否存在至少1只满足第三步过滤条件（与卡组确认的怪兽仅有1项相同且能加入手牌）的怪兽
		and Duel.IsExistingMatchingCard(c89558743.filter3,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤卡组中最终加入手牌的怪兽：必须是怪兽卡、能加入手牌、与卡组确认的怪兽仅有1项相同
function c89558743.filter3(c,mc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c89558743.same_check(c,mc)
end
-- 效果发动的目标过滤与操作信息注册
function c89558743.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：手牌中是否存在至少1只满足第一步过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89558743.filter1,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置操作信息：预计将手牌和卡组的各1张卡（共2张）里侧除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息：预计从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑：依次展示手牌怪兽、确认卡组怪兽、里侧除外手牌怪兽、检索最终怪兽并里侧除外卡组怪兽
function c89558743.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡（手牌怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌选择1只满足第一步过滤条件的怪兽
	local g1=Duel.SelectMatchingCard(tp,c89558743.filter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	if g1:GetCount()==0 then return end
	-- 将选中的手牌怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g1)
	-- 提示玩家选择要给对方确认的卡（卡组怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从卡组选择1只与展示的手牌怪兽仅有1项相同的怪兽
	local g2=Duel.SelectMatchingCard(tp,c89558743.filter2,tp,LOCATION_DECK,0,1,1,nil,tp,g1:GetFirst())
	-- 将选中的卡组怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g2)
	-- 如果成功确认了卡组怪兽，则将展示的手牌怪兽里侧除外，并判断是否除外成功
	if g2:GetCount()~=0 and Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使后续的“加入手牌并除外卡组怪兽”与“除外手牌怪兽”不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只与确认的卡组怪兽仅有1项相同的怪兽
		local g3=Duel.SelectMatchingCard(tp,c89558743.filter3,tp,LOCATION_DECK,0,1,1,nil,g2:GetFirst())
		if g3:GetCount()>0 then
			-- 将选中的最终怪兽加入玩家手牌
			Duel.SendtoHand(g3,nil,REASON_EFFECT)
			-- 将加入手牌的怪兽给对方玩家确认
			Duel.ConfirmCards(1-tp,g3)
			-- 将卡组中确认的那只怪兽里侧除外
			Duel.Remove(g2,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
