--レベル変換実験室
-- 效果：
-- 选择自己手卡1张怪兽卡给对方看，投掷1次骰子。出现的数目是1的场合，选择的怪兽送去墓地。出现的数目是2至6的场合，这个回合的结束阶段前，这只怪兽的等级变为投掷的数目。
function c84397023.initial_effect(c)
	-- 选择自己手卡1张怪兽卡给对方看，投掷1次骰子。出现的数目是1的场合，选择的怪兽送去墓地。出现的数目是2至6的场合，这个回合的结束阶段前，这只怪兽的等级变为投掷的数目。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c84397023.tg)
	e1:SetOperation(c84397023.op)
	c:RegisterEffect(e1)
end
-- 效果发动的目标与条件检查函数
function c84397023.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1张怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) end
end
-- 效果处理的执行函数
function c84397023.op(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从自己手牌中选择1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	if g:GetCount()>0 then
		-- 将选择的卡片给对方确认
		Duel.ConfirmCards(1-tp,g)
		-- 进行1次投掷骰子，并获取投掷结果
		local ct=Duel.TossDice(tp,1)
		-- 如果投掷结果为1，则将选择的怪兽送去墓地
		if ct==1 then Duel.SendtoGrave(g,REASON_EFFECT)
		elseif ct>=2 and ct<=6 then
			-- 出现的数目是2至6的场合，这个回合的结束阶段前，这只怪兽的等级变为投掷的数目。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(ct)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffect(e1)
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
		end
	end
end
