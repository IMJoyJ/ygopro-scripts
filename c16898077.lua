--ジャイアント・ボマー・エアレイド
-- 效果：
-- 这张卡不能通常召唤。「召唤反应机·大式」的效果才能特殊召唤。1回合1次，可以把1张手卡送去墓地让对方场上存在的1张卡破坏。此外，对方回合1次，可以从下面效果选择1个发动。
-- ●对方对怪兽的召唤、特殊召唤成功时才能发动。把那些怪兽破坏，给与对方基本分800分伤害。
-- ●对方把卡盖放时才能发动。把那些卡破坏，给与对方基本分800分伤害。
function c16898077.initial_effect(c)
	c:EnableReviveLimit()
	-- 此效果使该卡不能通常召唤，只能通过「召唤反应机·大式」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把1张手卡送去墓地让对方场上存在的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16898077,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c16898077.descost)
	e2:SetTarget(c16898077.destg)
	e2:SetOperation(c16898077.desop)
	c:RegisterEffect(e2)
	-- 对方对怪兽的召唤、特殊召唤成功时才能发动。把那些怪兽破坏，给与对方基本分800分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16898077,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(c16898077.damcon)
	e3:SetTarget(c16898077.damtg)
	e3:SetOperation(c16898077.damop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 对方把卡盖放时才能发动。把那些卡破坏，给与对方基本分800分伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16898077,2))  --"盖卡破坏"
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_MSET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCondition(c16898077.damcon2)
	e5:SetTarget(c16898077.damtg2)
	e5:SetOperation(c16898077.damop2)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SSET)
	c:RegisterEffect(e6)
	-- 对方把卡盖放时才能发动。把那些卡破坏，给与对方基本分800分伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(16898077,2))  --"盖卡破坏"
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_CHANGE_POS)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e7:SetCondition(c16898077.damcon3)
	e7:SetTarget(c16898077.damtg3)
	e7:SetOperation(c16898077.damop3)
	c:RegisterEffect(e7)
end
-- 检查玩家手牌中是否存在可作为费用送去墓地的卡。
function c16898077.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可作为费用送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手牌送去墓地作为费用。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置选择目标的函数，用于破坏对方场上的一张卡。
function c16898077.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可破坏的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张卡作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作。
function c16898077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 设置触发条件，仅在对方回合时生效。
function c16898077.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，用于筛选对方召唤或特殊召唤成功的怪兽。
function c16898077.dfilter(c,e,sp)
	return c:IsSummonPlayer(sp) and (not e or c:IsRelateToEffect(e))
end
-- 设置发动时的目标和操作信息。
function c16898077.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c16898077.dfilter,1,nil,nil,1-tp) end
	local g=eg:Filter(c16898077.dfilter,nil,nil,1-tp)
	-- 设置当前效果的目标卡。
	Duel.SetTargetCard(g)
	-- 设置破坏操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置造成800伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果。
function c16898077.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c16898077.dfilter,nil,e,1-tp)
	-- 检查效果是否有效并执行破坏和伤害。
	if e:GetHandler():IsRelateToEffect(e) and g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 给对方造成800点伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- 设置触发条件，仅在对方回合且为对方操作时生效。
function c16898077.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方且为对方操作。
	return Duel.GetTurnPlayer()~=tp and rp==1-tp
end
-- 设置发动时的目标和操作信息。
function c16898077.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c16898077.sfilter,1,nil) end
	local g=eg:Filter(c16898077.sfilter,nil)
	-- 设置当前效果的目标卡。
	Duel.SetTargetCard(g)
	-- 设置破坏操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
	-- 设置造成800伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果。
function c16898077.damop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c16898077.sfilter,nil,e)
	-- 检查效果是否有效并执行破坏和伤害。
	if e:GetHandler():IsRelateToEffect(e) and g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 给对方造成800点伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- 设置触发条件，仅在对方回合且为对方操作时生效。
function c16898077.damcon3(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方且为对方操作。
	return Duel.GetTurnPlayer()~=tp and rp==1-tp
end
-- 过滤函数，用于筛选对方盖放的卡。
function c16898077.sfilter(c,e)
	return c:IsFacedown() and (not e or c:IsRelateToEffect(e))
end
-- 设置发动时的目标和操作信息。
function c16898077.damtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c16898077.sfilter,1,nil) end
	local g=eg:Filter(c16898077.sfilter,nil)
	-- 设置当前效果的目标卡。
	Duel.SetTargetCard(g)
	-- 设置破坏操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置造成800伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果。
function c16898077.damop3(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c16898077.sfilter,nil,e)
	-- 检查效果是否有效并执行破坏和伤害。
	if e:GetHandler():IsRelateToEffect(e) and g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 给对方造成800点伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
