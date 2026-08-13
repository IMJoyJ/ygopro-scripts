--アマゾネスの鎖使い
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时，支付1500基本分才能发动。把对方手卡确认，从那之中选1只怪兽加入自己手卡。
function c29654737.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时，支付1500基本分才能发动。把对方手卡确认，从那之中选1只怪兽加入自己手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29654737,0))  --"手牌夺取"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c29654737.condition)
	e1:SetCost(c29654737.cost)
	e1:SetOperation(c29654737.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在墓地且被战斗破坏送去墓地，同时对方手牌数不为0。
function c29654737.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		-- 追加条件：确认对方手牌中至少存在1张卡，满足发动前置要求。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
end
-- 定义效果的发动代价：检查并支付1500基本分。
function c29654737.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：返回玩家当前能否支付1500基本分，用于系统判断是否可发动。
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 实际支付1500基本分作为发动代价。
	Duel.PayLPCost(tp,1500)
end
-- 效果处理：确认对方全部手牌，从中选择1只怪兽加入自己手牌，处理完毕后洗切对方手牌。
function c29654737.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家当前的全部手牌。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 将对方全部手牌展示给己方玩家确认。
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		if tg:GetCount()>0 then
			-- 弹出选择提示，要求从符合条件的怪兽中选择1张加入手牌。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 将选中的怪兽加入己方手牌，移动原因是效果处理。
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
		end
		-- 洗切对方手牌，重置因确认与取走卡片造成的手牌顺序。
		Duel.ShuffleHand(1-tp)
	end
end
