--グレイモヤ不発弾
-- 效果：
-- 选择场上表侧攻击表示存在的2只怪兽发动。选择的怪兽从场上离开时，这张卡破坏。这张卡破坏时，选择的怪兽破坏。
function c42167046.initial_effect(c)
	-- 『选择场上表侧攻击表示存在的2只怪兽发动。』本代码注册了发动效果，并在处理时将所选2只怪兽设为永续对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c42167046.target)
	e1:SetOperation(c42167046.operation)
	c:RegisterEffect(e1)
	-- 『这张卡破坏时，选择的怪兽破坏。』本代码注册了此卡因破坏离场时的持续效果，条件为自身因破坏离场，成功后破坏其永续对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c42167046.descon1)
	e2:SetOperation(c42167046.desop1)
	c:RegisterEffect(e2)
	-- 『选择的怪兽从场上离开时，这张卡破坏。』本代码注册了全场持续效果，当所选择的怪兽离场时破坏此卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c42167046.descon2)
	e3:SetOperation(c42167046.desop2)
	c:RegisterEffect(e3)
end
-- 发动效果的目标判定与选择函数：仅允许选择主要怪兽区表侧攻击表示的怪兽；在发动时选出2只作为对象。
function c42167046.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsPosition(POS_FACEUP_ATTACK) end
	-- 发动条件检查：确认双方场上合计存在至少2只表侧攻击表示怪兽（Card.IsPosition作为过滤函数，额外参数POS_FACEUP_ATTACK指定表侧攻击表示），否则无法发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,POS_FACEUP_ATTACK) end
	-- 向操作玩家发出选择提示，提示文字为“请选择表侧攻击表示的怪兽”，同时缓存选择消息供后续选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 调用SelectTarget选出2只表侧攻击表示怪兽，并将它们登记为当前连锁的对象卡，供效果处理时获取。
	local g=Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil,POS_FACEUP_ATTACK)
end
-- 发动效果处理：获取本连锁登记的对象卡，若对象仍与本效果相关（如未离场），则将它们全部设为这张卡的永续对象，用于追踪。
function c42167046.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁的TARGET_CARDS中筛选出仍然与本效果相关联的卡，作为要建立永续联系的卡组，排除已被无效或离场导致关联丢失的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		c:SetCardTarget(tc)
		tc=g:GetNext()
	end
end
-- descon1的条件：仅当这张卡因为『被破坏』而离场时，才允许执行后续的破坏对象效果（即这张卡是被破坏的场合）。
function c42167046.descon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 当这张卡被破坏时，从它的永续对象中筛选出仍位于怪兽区的怪兽，并全部破坏，实现『这张卡破坏时，选择的怪兽破坏』。
function c42167046.desop1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 以『效果』为原因破坏这些对象怪兽，触发对应的破坏事件；此操作会实际执行破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- descon2的条件：检查离场事件eg中是否含有这张卡的永续对象（第1只或第2只被选择的怪兽），且至少有一个对象离场；若没有对象则不成立。
function c42167046.descon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	local g=c:GetCardTarget()
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return eg:IsContains(tc1) or (tc2 and eg:IsContains(tc2))
end
-- 当被选择的怪兽从场上离开时，以效果破坏这张卡，触发『选择的怪兽从场上离开时，这张卡破坏』的后续处理。
function c42167046.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以『效果』为原因破坏这张卡自身，实际执行‘这张卡破坏’这一操作。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
