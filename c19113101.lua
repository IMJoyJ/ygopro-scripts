--プリベントマト
-- 效果：
-- 把墓地的这张卡从游戏中除外才能发动。这个回合，自己受到的效果伤害变成0。这个效果在对方回合才能发动。
function c19113101.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外才能发动。这个回合，自己受到的效果伤害变成0。这个效果在对方回合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19113101,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c19113101.condition)
	-- 设置效果的发动COST为把墓地的这张卡从游戏中除外。
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c19113101.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数：仅在当前回合玩家不是tp（即对方回合）时满足发动条件。
function c19113101.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是效果持有者tp，从而确保只能在对方回合发动。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义效果发动成功后的处理：给自己适用本回合效果伤害变成0的持续效果，并注册对应的EFFECT_NO_EFFECT_DAMAGE标记。
function c19113101.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c19113101.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将改变效果伤害为0的持续效果e1注册到tp，使其在该回合适用。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将EFFECT_NO_EFFECT_DAMAGE标记效果e2注册到tp，记录己方本回合已受到效果伤害变成0的保护状态。
	Duel.RegisterEffect(e2,tp)
end
-- 定义伤害替代值函数：当伤害原因为效果伤害（REASON_EFFECT）时返回0，否则保留原伤害值。
function c19113101.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
