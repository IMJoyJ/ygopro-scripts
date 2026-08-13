--揺れる眼差し
-- 效果：
-- ①：双方的灵摆区域的卡全部破坏。那之后，这个效果破坏的卡数量的以下效果适用。
-- ●1张以上：给与对方500伤害。
-- ●2张以上：可以从卡组把1只灵摆怪兽加入手卡。
-- ●3张以上：可以选场上1张卡除外。
-- ●4张：可以从卡组把1张「摇晃的目光」加入手卡。
function c31222701.initial_effect(c)
	-- ①：双方的灵摆区域的卡全部破坏。那之后，这个效果破坏的卡数量的以下效果适用：●1张以上：给与对方500伤害；●2张以上：可以从卡组把1只灵摆怪兽加入手卡；●3张以上：可以选场上1张卡除外；●4张：可以从卡组把1张「摇晃的目光」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31222701.target)
	e1:SetOperation(c31222701.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动时的目标判定与操作信息登记：检查双方灵摆区域是否有卡，若有则取得双方灵摆区域全部卡并登记破坏与伤害的操作信息。
function c31222701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查双方灵摆区域是否存在卡，若不存在则不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,LOCATION_PZONE)>0 end
	-- 获取双方灵摆区域的全部卡，用于后续破坏及数量统计。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 将破坏双方灵摆区域全部卡的操作信息登记到当前连锁，g为对象，g:GetCount()为预计破坏数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 将给对方造成500点伤害的操作信息登记到当前连锁，对象玩家为对方，数值500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 定义“2张以上”分支的检索过滤器：筛选卡组中类型为灵摆且可以被加入手卡的怪兽。
function c31222701.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 定义“4张”分支的检索过滤器：筛选卡组中卡名为「摇晃的目光」且可以被加入手卡的卡。
function c31222701.thfilter2(c)
	return c:IsCode(31222701) and c:IsAbleToHand()
end
-- 定义效果处理函数：实际破坏双方灵摆区域所有卡并记录数量ct；根据ct依次处理各分支：1张以上时给予对方500伤害；2张以上时可选1只灵摆怪兽加入手卡；3张以上时可选场上1张卡除外；4张时可选1张「摇晃的目光」加入手卡。
function c31222701.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理时重新获取双方灵摆区域当前存在的全部卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	-- 以效果原因破坏这些卡，返回实际被破坏的数量ct，用于决定后续适用的效果分支。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>=1 then
		-- 中断当前效果处理流程，使破坏与后续效果视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 给对方玩家造成500点伤害，伤害原因为效果。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	-- 从卡组筛选出所有满足thfilter1条件的灵摆怪兽，作为“2张以上”分支的检索候选组。
	local hg1=Duel.GetMatchingGroup(c31222701.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 判定是否满足“2张以上”分支：实际破坏数量ct>=2、候选组非空，且玩家选择同意发动从卡组把1只灵摆怪兽加入手卡的效果。
	if ct>=2 and hg1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31222701,0)) then  --"是否从卡组把1只灵摆怪兽加入手卡？"
		-- 中断效果流程，使检索处理与前一步伤害处理视为不同时，保证时点正确。
		Duel.BreakEffect()
		-- 向玩家显示选择提示“请选择要加入手牌的卡”，用于后续从候选组中选择卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local shg1=hg1:Select(tp,1,1,nil)
		-- 将选择的一张灵摆怪兽从卡组加入其持有者的手牌，原因为效果。
		Duel.SendtoHand(shg1,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的那张卡，以公开检索到的卡。
		Duel.ConfirmCards(1-tp,shg1)
	end
	-- 获取场上所有可被除外的卡，并排除本卡自身，作为“3张以上”分支的候选组。
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 判定是否满足“3张以上”分支：实际破坏数量ct>=3、存在可除外的候选卡，且玩家选择同意除外场上1张卡。
	if ct>=3 and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31222701,1)) then  --"是否选场上1张卡除外？"
		-- 中断效果流程，使除外处理与之前的处理视为不同时，保证时点正确。
		Duel.BreakEffect()
		-- 显示选择提示“请选择要除外的卡”，供玩家从候选组中选择1张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local srg=rg:Select(tp,1,1,nil)
		-- 将选择的那张卡以表侧表示除外，原因为效果。
		Duel.Remove(srg,POS_FACEUP,REASON_EFFECT)
	end
	-- 从卡组筛选出所有满足thfilter2条件的「摇晃的目光」卡，作为“4张”分支的检索候选组。
	local hg2=Duel.GetMatchingGroup(c31222701.thfilter2,tp,LOCATION_DECK,0,nil)
	-- 判定是否满足“4张”分支：实际破坏数量ct==4、候选组非空，且玩家选择同意从卡组把1张「摇晃的目光」加入手卡。
	if ct==4 and hg2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31222701,2)) then  --"是否从卡组把1张「摇晃的目光」加入手卡？"
		-- 中断效果流程，使加入手卡处理与前一步处理视为不同时，保证时点正确。
		Duel.BreakEffect()
		-- 显示选择提示“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local shg2=hg2:Select(tp,1,1,nil)
		-- 将选择的那张「摇晃的目光」从卡组加入其持有者的手牌，原因为效果。
		Duel.SendtoHand(shg2,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的那张「摇晃的目光」。
		Duel.ConfirmCards(1-tp,shg2)
	end
end
