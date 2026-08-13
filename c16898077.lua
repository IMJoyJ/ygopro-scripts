--ジャイアント・ボマー・エアレイド
-- 效果：
-- 这张卡不能通常召唤。「召唤反应机·大式」的效果才能特殊召唤。1回合1次，可以把1张手卡送去墓地让对方场上存在的1张卡破坏。此外，对方回合1次，可以从下面效果选择1个发动。
-- ●对方对怪兽的召唤、特殊召唤成功时才能发动。把那些怪兽破坏，给与对方基本分800分伤害。
-- ●对方把卡盖放时才能发动。把那些卡破坏，给与对方基本分800分伤害。
function c16898077.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，「召唤反应机·大式」的效果才能特殊召唤。
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
	-- 对方对怪兽的召唤成功时才能发动。把那些怪兽破坏，给与对方基本分800分伤害。
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
-- e2（1回合1次把手卡送墓破坏场上卡片）的发动代价函数：chk=0时检查手卡是否有可送墓的卡，有则提示选择并选1张手卡送去墓地作为COST。
function c16898077.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段判断自己手卡是否存在至少1张可以作为代价送去墓地的卡，以确定效果是否可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示“请选择要送去墓地的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己手卡中选择1张可作为代价送去墓地的卡，作为后续送墓的对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡以代价（REASON_COST）送去墓地，完成发动代价的支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- e2的取对象目标选择函数：从对方场上选择1张卡作为破坏对象，并设置破坏的操作信息。
function c16898077.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在目标选择阶段检查对方场上是否存在至少1张可以作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选择的对象卡登记为将被破坏的卡（数量1），便于其他效果响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- e2的效果处理函数：在效果结算时，将之前选择的对象卡破坏。
function c16898077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中选择的第1张对象卡（即破坏对象）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- e3/e4（对方召唤/特殊召唤成功时）的发动条件函数：仅当当前回合玩家不是这张卡的控制者（即对方回合）时才满足。
function c16898077.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者（对方回合），满足“对方回合”的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选由指定玩家召唤/特殊召唤成功的怪兽，并（传入e时）检查该怪兽是否仍与效果e关联。
function c16898077.dfilter(c,e,sp)
	return c:IsSummonPlayer(sp) and (not e or c:IsRelateToEffect(e))
end
-- e3/e4的目标函数：从触发事件中选出由对方玩家召唤/特殊召唤成功的怪兽，将其设为对象，并设置破坏与伤害的操作信息。
function c16898077.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c16898077.dfilter,1,nil,nil,1-tp) end
	local g=eg:Filter(c16898077.dfilter,nil,nil,1-tp)
	-- 将筛选出的召唤/特殊召唤成功的怪兽组设为当前连锁的处理对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：将上述怪兽组全部登记为将被破坏的卡，数量为组内卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：效果处理时将给与对方玩家800点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- e3/e4的效果处理函数：将触发事件中仍与效果关联的、由对方玩家召唤的怪兽破坏；若破坏成功则给与对方800伤害。
function c16898077.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c16898077.dfilter,nil,e,1-tp)
	-- 判定效果是否继续处理：发动效果的这张卡仍与效果关联、要破坏的怪兽组非空、且执行破坏后至少有1张被效果破坏成功。
	if e:GetHandler():IsRelateToEffect(e) and g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 以效果原因给与对方玩家（1-tp）800点基本分伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- e5/e6（对方把怪兽/魔陷盖放时）的发动条件函数：需要在对方回合且该盖放操作由对方玩家执行。
function c16898077.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是对方回合且触发盖放操作的操作者是对方玩家。
	return Duel.GetTurnPlayer()~=tp and rp==1-tp
end
-- e5/e6的目标函数：将触发事件中被对方盖放的卡设为对象，并设置破坏与伤害的操作信息。
function c16898077.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c16898077.sfilter,1,nil) end
	local g=eg:Filter(c16898077.sfilter,nil)
	-- 将筛选出的被盖放的卡组设为当前连锁的处理对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：将eg中全部被盖放的卡登记为将被破坏的卡，数量为eg的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
	-- 设置操作信息：效果处理时将给与对方玩家800点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- e5/e6的效果处理函数：将触发事件中仍与效果关联的被盖放的卡破坏；若破坏成功则给与对方800伤害。
function c16898077.damop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c16898077.sfilter,nil,e)
	-- 判定效果是否继续处理：发动者仍与效果关联、要破坏的卡组非空、且破坏成功。
	if e:GetHandler():IsRelateToEffect(e) and g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 以效果原因给与对方玩家（1-tp）800点基本分伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
-- e7（对方将卡覆盖/变为里侧表示时）的发动条件函数：需要在对方回合且该操作由对方玩家执行。
function c16898077.damcon3(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是对方回合且触发变里侧操作的操作者是对方玩家。
	return Duel.GetTurnPlayer()~=tp and rp==1-tp
end
-- 筛选里侧表示且（传入e时）仍与效果e关联的卡。
function c16898077.sfilter(c,e)
	return c:IsFacedown() and (not e or c:IsRelateToEffect(e))
end
-- e7的目标函数：从触发事件中选出里侧表示的卡，将其设为对象，并设置破坏与伤害的操作信息。
function c16898077.damtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c16898077.sfilter,1,nil) end
	local g=eg:Filter(c16898077.sfilter,nil)
	-- 将筛选出的里侧表示的卡组设为当前连锁的处理对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：将g中全部里侧表示的卡登记为将被破坏的卡，数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：效果处理时将给与对方玩家800点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- e7的效果处理函数：将触发事件中仍与效果关联的里侧表示的卡破坏；若破坏成功则给与对方800伤害。
function c16898077.damop3(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c16898077.sfilter,nil,e)
	-- 判定效果是否继续处理：发动者仍与效果关联、要破坏的卡组非空、且破坏成功。
	if e:GetHandler():IsRelateToEffect(e) and g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 以效果原因给与对方玩家（1-tp）800点基本分伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
