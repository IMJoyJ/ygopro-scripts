--ゴーストリック・アウト
-- 效果：
-- 把手卡1只名字带有「鬼计」的怪兽给对方观看才能发动。这个回合，自己场上的名字带有「鬼计」的卡以及里侧守备表示存在的怪兽不会成为卡的效果的对象，不会被卡的效果破坏。
function c50527144.initial_effect(c)
	-- 把把手卡1只名字带有「鬼计」的怪兽给对方观看才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c50527144.cost)
	e1:SetOperation(c50527144.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手牌中是否存在名字带有「鬼计」且为怪兽卡但未公开的卡片。
function c50527144.cfilter(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果处理函数，用于支付费用：选择并确认一张手牌中的「鬼计」怪兽。
function c50527144.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足费用条件：检查手牌中是否存在至少1张符合条件的「鬼计」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50527144.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认给对方的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择1张符合条件的「鬼计」怪兽。
	local g=Duel.SelectMatchingCard(tp,c50527144.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选的卡公开给对方查看。
	Duel.ConfirmCards(1-tp,g)
	-- 将自己的手牌洗切。
	Duel.ShuffleHand(tp)
end
-- 效果发动处理函数，为场上「鬼计」卡和里侧守备表示怪兽设置保护效果。
function c50527144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册一个使「鬼计」卡不会被效果破坏的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c50527144.tgfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册到场上，使其生效。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(1)
	-- 将效果e2注册到场上，使其生效。
	Duel.RegisterEffect(e2,tp)
end
-- 目标过滤函数，判断是否为场上的「鬼计」卡或里侧守备表示的怪兽。
function c50527144.tgfilter(e,c)
	return (c:IsFaceup() and c:IsSetCard(0x8d)) or (c:IsFacedown() and c:IsLocation(LOCATION_MZONE))
end
