--グリグル
-- 效果：
-- 场上表侧表示存在的这张卡的控制权转移给对方时，自己回复3000基本分。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c95744531.initial_effect(c)
	-- 场上表侧表示存在的这张卡的控制权转移给对方时，自己回复3000基本分。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95744531,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CONTROL_CHANGED)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetTarget(c95744531.target)
	e1:SetOperation(c95744531.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与条件，检查自身是否处于连锁中，并设置回复生命值的操作信息。
function c95744531.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置操作信息，表明该效果将使原本的控制者（1-tp）回复3000基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,3000)
end
-- 定义效果处理的执行逻辑，使原本的控制者（1-tp）回复3000基本分。
function c95744531.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 由效果使原本的控制者（1-tp）回复3000基本分。
	Duel.Recover(1-tp,3000,REASON_EFFECT)
end
