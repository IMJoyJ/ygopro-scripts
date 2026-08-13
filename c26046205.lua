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
-- 判断效果拥有者（这张卡）是否为表侧攻击表示，从而满足“场上表侧攻击表示存在”的发动条件。
function c26046205.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 效果发动时的目标处理：判定阶段返回 true 表示效果可以正常发动，并设置抽卡效果的操作信息，指定抽卡方为发动者 tp、抽卡数量为 1。
function c26046205.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的抽卡操作信息，声明将进行 CATEGORY_DRAW 抽卡效果，抽卡玩家为 tp，抽卡数量为 1（targets 为 nil 表示不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理阶段的实际执行函数：让发动者 tp 以效果原因抽 1 张卡。
function c26046205.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行抽卡操作：玩家 tp 抽 1 张卡，原因是效果（REASON_EFFECT）。
	Duel.Draw(tp,1,REASON_EFFECT)
end
