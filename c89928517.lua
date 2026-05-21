--通販売員
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。双方玩家各自把1张手卡给对方观看。给人观看的卡是相同种类的场合，那个种类的以下效果适用。
-- ●怪兽：双方玩家各自可以把给人观看的怪兽特殊召唤。
-- ●魔法：双方玩家各自从卡组抽2张。
-- ●陷阱：双方玩家各自从卡组选2张卡送去墓地。
function c89928517.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。双方玩家各自把1张手卡给对方观看。给人观看的卡是相同种类的场合，那个种类的以下效果适用。●怪兽：双方玩家各自可以把给人观看的怪兽特殊召唤。●魔法：双方玩家各自从卡组抽2张。●陷阱：双方玩家各自从卡组选2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c89928517.target)
	e1:SetOperation(c89928517.operation)
	c:RegisterEffect(e1)
end
-- 过滤未给对方观看（非公开状态）的卡片
function c89928517.filter(c)
	return not c:IsPublic()
end
-- 效果发动时的目标确认函数（检查双方手牌中是否存在未公开的卡）
function c89928517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方手牌中是否都至少有1张未公开的卡
	if chk==0 then return Duel.GetMatchingGroupCount(c89928517.filter,tp,LOCATION_HAND,0,nil)*Duel.GetMatchingGroupCount(c89928517.filter,tp,0,LOCATION_HAND,nil)>0 end
end
-- 效果处理函数（双方展示手牌并根据卡片种类适用对应效果）
function c89928517.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手牌中所有未公开的卡
	local hg1=Duel.GetMatchingGroup(c89928517.filter,tp,LOCATION_HAND,0,nil)
	-- 获取对方手牌中所有未公开的卡
	local hg2=Duel.GetMatchingGroup(c89928517.filter,tp,0,LOCATION_HAND,nil)
	if #hg1==0 or #hg2==0 then return end
	-- 提示自己选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc1=hg1:Select(tp,1,1,nil):GetFirst()
	-- 提示对方选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc2=hg2:Select(1-tp,1,1,nil):GetFirst()
	local tg=Group.FromCards(tc1,tc2)
	-- 向双方玩家展示各自选择的卡
	Duel.ConfirmCards(tp,tg)
	if tc1:IsType(TYPE_MONSTER) and tc2:IsType(TYPE_MONSTER) then
		local i=0
		local p=tp
		while i<=1 do
			local tc=tg:Filter(Card.IsControler,nil,p):GetFirst()
			-- 检查当前处理玩家的怪兽区域是否有空位
			if Duel.GetLocationCount(p,LOCATION_MZONE,p)>0
				and tc:IsCanBeSpecialSummoned(e,0,p,false,false)
				-- 询问玩家是否选择特殊召唤该怪兽
				and Duel.SelectYesNo(p,aux.Stringid(89928517,1)) then  --"是否特殊召唤？"
				-- 逐步将展示的怪兽以表侧表示特殊召唤到自身场上
				Duel.SpecialSummonStep(tc,0,p,p,false,false,POS_FACEUP)
			end
			i=i+1
			p=1-tp
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	elseif tc1:IsType(TYPE_SPELL) and tc2:IsType(TYPE_SPELL) then
		-- 让自己从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
		-- 让对方从卡组抽2张卡
		Duel.Draw(1-tp,2,REASON_EFFECT)
	elseif tc1:IsType(TYPE_TRAP) and tc2:IsType(TYPE_TRAP)
		-- 检查自己卡组中是否存在至少2张可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,2,nil)
		-- 检查对方卡组中是否存在至少2张可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_DECK,2,nil) then
		for p=0,1 do
			-- 提示当前处理玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让当前处理玩家从自身卡组选择2张卡
			local g=Duel.SelectMatchingCard(p,Card.IsAbleToGrave,p,LOCATION_DECK,0,2,2,nil)
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 洗切对方的手牌
	Duel.ShuffleHand(1-tp)
end
