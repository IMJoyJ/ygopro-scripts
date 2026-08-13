--ゴーストリック・アウト
-- 效果：
-- 把手卡1只名字带有「鬼计」的怪兽给对方观看才能发动。这个回合，自己场上的名字带有「鬼计」的卡以及里侧守备表示存在的怪兽不会成为卡的效果的对象，不会被卡的效果破坏。
function c50527144.initial_effect(c)
	-- 把手卡1只名字带有「鬼计」的怪兽给对方观看才能发动。这个回合，自己场上的名字带有「鬼计」的卡以及里侧守备表示存在的怪兽不会成为卡的效果的对象，不会被卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50527144.cost)
	e1:SetOperation(c50527144.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：手牌中名字带有「鬼计」的怪兽卡，且当前为非公开状态（未被展示给对方）。
function c50527144.cfilter(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 发动代价处理：先检查手牌是否存在符合条件的鬼计怪兽；存在则选择1张交给对方确认，然后洗切手牌，完成‘给对方观看’的cost。
function c50527144.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：确认自己的手牌中是否存在至少1只满足cfilter条件的鬼计怪兽（名字带「鬼计」的怪兽且未公开），有则可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50527144.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示‘请选择给对方确认的卡’的选择提示，引导玩家选择要展示的手牌怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己的手牌中选择1张满足cfilter条件的鬼计怪兽作为发动代价（由玩家tp选择）。
	local g=Duel.SelectMatchingCard(tp,c50527144.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的那张手牌怪兽展示给对方玩家（1-tp），完成‘给对方观看’的要求。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌，避免通过展示后手牌顺序暴露信息；同时重置洗牌检测状态。
	Duel.ShuffleHand(tp)
end
-- 效果处理：为自己场上的保护对象（表侧表示的「鬼计」卡以及里侧守备表示怪兽）附加两个持续效果：不会被卡的效果破坏、不会成为卡的效果的对象，均持续到回合结束。
function c50527144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的名字带有「鬼计」的卡以及里侧守备表示存在的怪兽不会成为卡的效果的对象，不会被卡的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c50527144.tgfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将e1（不会被卡的效果破坏的永续效果）注册到玩家tp场上，使它为自己场上符合条件的卡提供破坏抗性，持续到回合结束重置。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(1)
	-- 将e2（不能成为卡的效果对象的永续效果）注册到玩家tp场上；e2由e1克隆而来，持续同样到回合结束，并带有EFFECT_FLAG_SET_AVAILABLE（影响里侧卡）和EFFECT_FLAG_IGNORE_IMMUNE（无视效果免疫）。
	Duel.RegisterEffect(e2,tp)
end
-- 保护对象判定：若某卡是表侧表示且卡名含有「鬼计」，或是里侧守备表示存在于主要怪兽区（即里侧守备表示怪兽），则该卡受到上述保护。
function c50527144.tgfilter(e,c)
	return (c:IsFaceup() and c:IsSetCard(0x8d)) or (c:IsFacedown() and c:IsLocation(LOCATION_MZONE))
end
