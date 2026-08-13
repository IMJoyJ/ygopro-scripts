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
-- 筛选手卡中持有『武神』字段的怪兽卡，且该卡能作为代价送去墓地。
function c23857661.cfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价检查：确认墓地的这张卡能否除外，以及手卡是否有1只满足条件的『武神』怪兽可丢弃。
function c23857661.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在至少1只满足 cfilter 条件的『武神』怪兽卡。
		and Duel.IsExistingMatchingCard(c23857661.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从游戏中除外自身（墓地的这张卡）作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡选择并丢弃1只满足条件的『武神』怪兽作为发动代价。
	Duel.DiscardHand(tp,c23857661.cfilter,1,1,REASON_COST)
end
-- 效果处理：创建“自己受到的伤害变成0”的领域效果并注册，同时复制一个效果设置效果伤害变为0的标记，两个效果均在结束阶段重置。
function c23857661.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将改变伤害数值为0的永续效果注册给当前玩家tp，使其在本回合生效。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“效果伤害变成0”的标记效果注册给tp，供其他效果检测；实际伤害减免由e1完成。
	Duel.RegisterEffect(e2,tp)
end
