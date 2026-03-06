--アマゾネスの鎖使い
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时，支付1500基本分才能发动。把对方手卡确认，从那之中选1只怪兽加入自己手卡。
function c29654737.initial_effect(c)
	-- 效果原文内容：①：这张卡被战斗破坏送去墓地时，支付1500基本分才能发动。把对方手卡确认，从那之中选1只怪兽加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29654737,0))  --"手牌夺取"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c29654737.condition)
	e1:SetCost(c29654737.cost)
	e1:SetOperation(c29654737.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断此卡是否因战斗破坏而送入墓地且对方手牌不为空
function c29654737.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		-- 规则层面作用：确保对方手牌数量大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
end
-- 规则层面作用：支付1500基本分作为发动条件
function c29654737.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否能支付1500基本分
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 规则层面作用：扣除玩家1500基本分
	Duel.PayLPCost(tp,1500)
end
-- 规则层面作用：执行效果主要处理流程，包括确认对方手牌、选择怪兽加入手牌并洗切对方手牌
function c29654737.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 规则层面作用：确认对方手牌内容
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		if tg:GetCount()>0 then
			-- 规则层面作用：提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 规则层面作用：将选中的怪兽加入己方手牌
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
		end
		-- 规则层面作用：洗切对方手牌
		Duel.ShuffleHand(1-tp)
	end
end
