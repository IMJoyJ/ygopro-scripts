--コアキメイルの障壁
-- 效果：
-- 自己墓地有「核成兽的钢核」2张以上存在的场合，对方怪兽的攻击宣言时才能发动。对方场上表侧攻击表示存在的怪兽全部破坏。
function c12216615.initial_effect(c)
	-- 记录此卡效果文本中记载的「核成兽的钢核」的卡号，使与此卡名相关的检索或判定能够识别。
	aux.AddCodeList(c,36623431)
	-- 自己墓地有「核成兽的钢核」2张以上存在的场合，对方怪兽的攻击宣言时才能发动。对方场上表侧攻击表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c12216615.condition)
	e1:SetTarget(c12216615.target)
	e1:SetOperation(c12216615.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：必须是在对方回合的攻击宣言时，且自己墓地存在2张以上「核成兽的钢核」。
function c12216615.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：当前不是自己的回合（即对方回合），且自己墓地存在至少2张卡号为36623431的「核成兽的钢核」。
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,2,nil,36623431)
end
-- 定义筛选条件：筛选出场上表侧攻击表示的怪兽，用于确定破坏对象。
function c12216615.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 定义效果发动时的目标选择与操作信息设置：确认存在可被破坏的对方表侧攻击怪兽，并登记要破坏的对象组及其数量。
function c12216615.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若对方场上不存在表侧攻击表示的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c12216615.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧攻击表示的怪兽组成一个组，作为后续破坏的对象候补。
	local g=Duel.GetMatchingGroup(c12216615.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置本次连锁的操作信息，宣告此效果包含破坏，破坏对象为g中的卡，数量为g的卡数，用于响应效果发动的判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理的实际操作：在效果结算时获取对方场上表侧攻击表示的怪兽，并将它们全部破坏。
function c12216615.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方场上当前所有表侧攻击表示的怪兽，确保破坏的是结算时的对象。
	local g=Duel.GetMatchingGroup(c12216615.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果破坏上述怪兽，送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
