--リチュア・チェイン
-- 效果：
-- 这张卡召唤成功时，从卡组上面把3张卡确认。确认的卡之中有仪式怪兽或者仪式魔法卡的场合，可以把那1张给对方观看并加入手卡。那之后，确认的卡用喜欢的顺序回到卡组上面。
function c66399675.initial_effect(c)
	-- 这张卡召唤成功时，从卡组上面把3张卡确认。确认的卡之中有仪式怪兽或者仪式魔法卡的场合，可以把那1张给对方观看并加入手卡。那之后，确认的卡用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66399675,0))  --"卡组确认"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c66399675.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：属于仪式卡片且可以加入手卡
function c66399675.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 效果处理：确认卡组顶端3张卡，可将其中1张仪式怪兽或仪式魔法卡加入手卡，其余卡按喜欢顺序放回卡组顶端
function c66399675.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组的卡片数量不足3张，则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	-- 让自己确认这3张卡
	Duel.ConfirmCards(tp,g)
	-- 如果确认的卡中存在仪式怪兽或仪式魔法卡，且玩家选择将其加入手卡
	if g:IsExists(c66399675.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(66399675,1)) then  --"是否要将仪式怪兽或者仪式魔法卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,c66399675.filter,1,1,nil)
		-- 禁用接下来的洗牌检测（防止因卡片加入手卡而自动洗牌）
		Duel.DisableShuffleCheck()
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家观看
		Duel.ConfirmCards(1-tp,sg)
		-- 手动洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 让自己将剩余的2张卡以喜欢的顺序放回卡组最上方
		Duel.SortDecktop(tp,tp,2)
	-- 否则（未加入手卡时），让自己将这3张卡以喜欢的顺序放回卡组最上方
	else Duel.SortDecktop(tp,tp,3) end
end
