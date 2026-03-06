--武神器－オキツ
-- 效果：
-- 把墓地的这张卡从游戏中除外，从手卡把1只名字带有「武神」的怪兽送去墓地才能发动。这个回合，自己受到的全部伤害变成0。这个效果在对方回合也能发动。
function c23857661.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，从手卡把1只名字带有「武神」的怪兽送去墓地才能发动。这个回合，自己受到的全部伤害变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23857661,0))  --"伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c23857661.cost)
	e1:SetOperation(c23857661.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手卡是否存在名字带有「武神」的怪兽
function c23857661.cfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 检查是否满足发动条件：墓地的这张卡可以除外，手卡存在1只名字带有「武神」的怪兽
function c23857661.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 手卡存在1只名字带有「武神」的怪兽
		and Duel.IsExistingMatchingCard(c23857661.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地的这张卡除外作为代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡丢弃1只名字带有「武神」的怪兽作为代价
	Duel.DiscardHand(tp,c23857661.cfilter,1,1,REASON_COST)
end
-- 将自己受到的全部伤害变成0的效果发动
function c23857661.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e2注册给玩家
	Duel.RegisterEffect(e2,tp)
end
