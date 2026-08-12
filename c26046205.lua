--悪シノビ
-- 效果：
-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，从自己卡组抽1张卡。
function c26046205.initial_effect(c)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26046205,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c26046205.condition)
	e1:SetTarget(c26046205.target)
	e1:SetOperation(c26046205.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡必须处于表侧攻击表示
function c26046205.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 效果处理目标：设置抽卡效果的处理信息
function c26046205.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标为己方玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时执行的操作：进行抽卡
function c26046205.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽卡操作，抽1张卡，抽卡原因为效果
	Duel.Draw(tp,1,REASON_EFFECT)
end
