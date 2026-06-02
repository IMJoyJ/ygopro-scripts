--終焉の覇王デミス
-- 效果：
-- 「世界不灭」降临
-- ①：这张卡的卡名只要在手卡·场上存在当作「终焉之王 迪米斯」使用。
-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己的仪式怪兽不会被战斗破坏。
-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
-- ④：1回合1次，支付2000基本分才能发动。场上的其他卡全部破坏，给与对方破坏的对方场上的卡数量×200伤害。
function c59913418.initial_effect(c)
	aux.AddCodeList(c,32828635)
	c:EnableReviveLimit()
	-- 注册卡名变更效果，使这张卡在手卡和怪兽区域存在时卡名当作「终焉之王 迪米斯」使用。
	aux.EnableChangeCode(c,72426662,LOCATION_MZONE+LOCATION_HAND)
	-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己的仪式怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c59913418.indcon)
	e2:SetTarget(c59913418.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_LPCOST_CHANGE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,1)
	e0:SetCondition(c59913418.costcon)
	e0:SetValue(c59913418.costval)
	c:RegisterEffect(e0)
	-- ④：1回合1次，支付2000基本分才能发动。场上的其他卡全部破坏，给与对方破坏的对方场上的卡数量×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c59913418.descost)
	e3:SetTarget(c59913418.destg)
	e3:SetOperation(c59913418.desop)
	c:RegisterEffect(e3)
	-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c59913418.matcon)
	e4:SetOperation(c59913418.matop)
	c:RegisterEffect(e4)
	-- ③：为只使用仪式怪兽作仪式召唤的这张卡的效果发动而支付的基本分变成不需要。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c59913418.valcheck)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 检查自身是否为仪式召唤。
function c59913418.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤出仪式怪兽作为战斗不破效果的适用对象。
function c59913418.indtg(e,c)
	return c:IsType(TYPE_RITUAL)
end
-- 过滤非仪式怪兽的卡片（用于检查仪式素材）。
function c59913418.mfilter(c)
	return not c:IsType(TYPE_RITUAL)
end
-- 检查自身是否带有只用仪式怪兽进行仪式召唤的标记。
function c59913418.costcon(e)
	return e:GetHandler():GetFlagEffect(59913418)>0
end
-- 若发动的是自身的效果，则将需要支付的LP代价改变为0。
function c59913418.costval(e,re,rp,val)
	if re and re:IsActivated() and re:GetHandler()==e:GetHandler() then
		return 0
	else return val end
end
-- 破坏效果的Cost：检查并支付2000点基本分。
function c59913418.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 玩家支付2000点基本分。
	Duel.PayLPCost(tp,2000)
end
-- 破坏效果的Target：检查场上是否存在其他卡，并设置破坏与伤害的操作信息。
function c59913418.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除这张卡以外的其他卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	local ct=g:FilterCount(Card.IsControler,nil,1-tp)
	-- 设置破坏操作信息，包含所有获取到的场上的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害操作信息，估算给与对方的伤害数值（对方场上卡数量×200）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 破坏效果的Operation：破坏场上其他卡，并根据破坏的对方卡数量给与对方伤害。
function c59913418.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除当前效果处理卡以外的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 因效果破坏这些卡。
	Duel.Destroy(g,REASON_EFFECT)
	-- 统计实际被破坏的卡中属于对方场上的卡片数量。
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,1-tp)
	if ct>0 then
		-- 给与对方被破坏的对方卡数量×200的伤害。
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end
-- 检查是否为仪式召唤，且仪式素材是否全部为仪式怪兽（通过Label判定）。
function c59913418.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 给自身注册一个特定Flag，表示该卡是仅用仪式怪兽作为素材仪式召唤的。
function c59913418.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(59913418,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 检查仪式召唤的素材，若全部为仪式怪兽，则将LabelObject的Label设为1，否则设为0。
function c59913418.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c59913418.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
