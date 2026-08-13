--DD魔導賢者コペルニクス
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的魔法卡的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「DD 魔导贤者 哥白尼」外的1张「DD」卡或「契约书」卡从卡组送去墓地。
function c46796664.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性，使其能够在灵摆区域发动作并参与灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46796664.splimit)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在灵摆区域存在才有1次，给与自己伤害的魔法卡的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(c46796664.discon)
	e2:SetOperation(c46796664.disop)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。除「DD 魔导贤者 哥白尼」外的1张「DD」卡或「契约书」卡从卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46796664,0))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,46796664)
	e3:SetTarget(c46796664.tgtg)
	e3:SetOperation(c46796664.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 灵摆召唤限制条件：进行灵摆召唤的怪兽若不具有「DD」字段（0xaf），则禁止该灵摆召唤。
function c46796664.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xaf) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 效果②的发动条件：存在可无效且未被无效的连锁，该连锁是魔法卡效果且会给这张卡的控制者造成伤害，并且此卡尚未发动过②效果（flag为0）。
function c46796664.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁是否可以被无效且尚未被无效。
	return Duel.IsChainNegatable(ev) and not Duel.IsChainDisabled(ev)
		-- 追加判断：效果来源为魔法卡，且该效果会对控制者造成伤害（符合aux.damcon1），并且此卡没有使用过②效果。
		and re:IsActiveType(TYPE_SPELL) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetFlagEffect(46796664)==0
end
-- 效果②的处理流程：选择发动后给此卡设置已使用标记，无效对应魔法效果，断开连锁处理并最终破坏此卡。
function c46796664.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家选择不发动此效果，则直接结束处理。
	if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	e:GetHandler():RegisterFlagEffect(46796664,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 若无效连锁失败，则中止后续破坏操作。
	if not Duel.NegateEffect(ev) then return end
	-- 中断当前效果处理，使之后的破坏处理视为另一次处理，避免造成错误时点。
	Duel.BreakEffect()
	-- 将这张卡自身以效果破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 送墓目标筛选条件：是「DD」或「契约书」字段的卡，且不是「DD 魔导贤者 哥白尼」，并且可以送去墓地。
function c46796664.tgfilter(c)
	return c:IsSetCard(0xaf,0xae) and not c:IsCode(46796664) and c:IsAbleToGrave()
end
-- 怪兽效果发动时的目标检查：卡组存在符合条件的卡才可发动，并设置从卡组送1张卡去墓地的操作信息。
function c46796664.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张满足tgfilter的卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46796664.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：从卡组将1张卡送去墓地，供「星尘龙」等卡或系统进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果的具体处理：从卡组选择1张符合条件的卡送去墓地。
function c46796664.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向控制者显示选择提示消息，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让控制者从卡组中选出1张满足tgfilter的卡（不取对象）。
	local g=Duel.SelectMatchingCard(tp,c46796664.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
