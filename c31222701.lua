--揺れる眼差し
-- 效果：
-- ①：双方的灵摆区域的卡全部破坏。那之后，这个效果破坏的卡数量的以下效果适用。
-- ●1张以上：给与对方500伤害。
-- ●2张以上：可以从卡组把1只灵摆怪兽加入手卡。
-- ●3张以上：可以选场上1张卡除外。
-- ●4张：可以从卡组把1张「摇晃的目光」加入手卡。
function c31222701.initial_effect(c)
	-- 效果原文：①：双方的灵摆区域的卡全部破坏。那之后，这个效果破坏的卡数量的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31222701.target)
	e1:SetOperation(c31222701.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件并设置连锁信息
function c31222701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断灵摆区域是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,LOCATION_PZONE)>0 end
	-- 效果作用：获取双方灵摆区域的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 效果作用：设置连锁信息，将破坏的卡数量记录到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 效果作用：设置连锁信息，将对对方造成500伤害记录到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果原文：●2张以上：可以从卡组把1只灵摆怪兽加入手卡。
function c31222701.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果原文：●4张：可以从卡组把1张「摇晃的目光」加入手卡。
function c31222701.thfilter2(c)
	return c:IsCode(31222701) and c:IsAbleToHand()
end
-- 效果作用：处理效果发动后的连锁处理
function c31222701.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取双方灵摆区域的卡组
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 效果作用：将灵摆区域的卡全部破坏并返回破坏数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>=1 then
		-- 效果作用：中断当前效果，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：给与对方500伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	-- 效果作用：检索满足条件的灵摆怪兽
	local hg1=Duel.GetMatchingGroup(c31222701.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 效果作用：判断是否满足条件并询问玩家是否发动效果
	if ct>=2 and hg1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31222701,0)) then  --"是否从卡组把1只灵摆怪兽加入手卡？"
		-- 效果作用：中断当前效果，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local shg1=hg1:Select(tp,1,1,nil)
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(shg1,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,shg1)
	end
	-- 效果作用：检索满足条件的可除外卡
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 效果作用：判断是否满足条件并询问玩家是否发动效果
	if ct>=3 and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31222701,1)) then  --"是否选场上1张卡除外？"
		-- 效果作用：中断当前效果，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local srg=rg:Select(tp,1,1,nil)
		-- 效果作用：将选中的卡除外
		Duel.Remove(srg,POS_FACEUP,REASON_EFFECT)
	end
	-- 效果作用：检索满足条件的「摇晃的目光」
	local hg2=Duel.GetMatchingGroup(c31222701.thfilter2,tp,LOCATION_DECK,0,nil)
	-- 效果作用：判断是否满足条件并询问玩家是否发动效果
	if ct==4 and hg2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31222701,2)) then  --"是否从卡组把1张「摇晃的目光」加入手卡？"
		-- 效果作用：中断当前效果，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local shg2=hg2:Select(tp,1,1,nil)
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(shg2,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,shg2)
	end
end
