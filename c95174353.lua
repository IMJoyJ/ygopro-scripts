--アメーバ
-- 效果：
-- 场上表侧表示存在的这张卡的控制权转移给对方时，对方受到2000分的伤害。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c95174353.initial_effect(c)
	-- 场上表侧表示存在的这张卡的控制权转移给对方时，对方受到2000分的伤害。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95174353,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CONTROL_CHANGED)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetTarget(c95174353.target)
	e1:SetOperation(c95174353.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标确认函数，检查自身是否已在连锁中，并设置伤害操作信息
function c95174353.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置操作信息，表明该效果的处理为给与玩家2000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
-- 定义效果处理的执行函数，给与玩家2000点伤害
function c95174353.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果给与当前控制者（即转移控制权后的对方玩家）2000点伤害
	Duel.Damage(tp,2000,REASON_EFFECT)
end
