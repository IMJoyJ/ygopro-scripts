--閃刀姫－ジーク
-- 效果：
-- 包含「闪刀姬」怪兽的怪兽2只
-- 这张卡不用连接召唤不能特殊召唤，自己对「闪刀姬-泽克」1回合只能有1次特殊召唤。
-- ①：这张卡连接召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下次的对方结束阶段除外。
-- ②：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这张卡的攻击力上升1000。那之后，作为对象的卡送去墓地。
function c75147529.initial_effect(c)
	c:SetSPSummonOnce(75147529)
	c:EnableReviveLimit()
	-- 作用：添加连接召唤手续，需要2只怪兽作为素材，且必须包含「闪刀姬」怪兽。
	aux.AddLinkProcedure(c,nil,2,2,c75147529.lcheck)
	-- 这张卡不用连接召唤不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 作用：设定特殊召唤限制为只能进行连接召唤。
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下次的对方结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75147529,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c75147529.rmcon)
	e2:SetTarget(c75147529.rmtg)
	e2:SetOperation(c75147529.rmop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这张卡的攻击力上升1000。那之后，作为对象的卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75147529,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c75147529.tgtg)
	e3:SetOperation(c75147529.tgop)
	c:RegisterEffect(e3)
end
-- 作用：连接素材检查函数，要求素材组中必须包含至少1只「闪刀姬」怪兽。
function c75147529.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1115)
end
-- 作用：效果①的发动条件：此卡是通过连接召唤特殊召唤成功的。
function c75147529.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 作用：效果①的对象过滤条件：场上表侧表示且可以被除外的怪兽。
function c75147529.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 作用：效果①的发动准备（Target阶段）：检查并选择场上1只表侧表示怪兽作为对象，并设置除外操作信息。
function c75147529.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c75147529.rmfilter(chkc) end
	-- 作用：在发动效果时，检查场上是否存在至少1只满足条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c75147529.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 作用：向发动效果的玩家提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 作用：让玩家选择1只满足条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c75147529.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 作用：设置效果处理信息，表示此效果将除外选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 作用：效果①的效果处理（Operation阶段）：将作为对象的怪兽暂时除外，并注册在下次对方结束阶段返回场上的延迟效果。
function c75147529.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 作用：获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 作用：如果对象怪兽在效果处理时仍适用此效果，则将其以效果原因暂时除外。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 那只怪兽直到下次的对方结束阶段除外。以这张卡以外的自己场上1张卡为对象才能发动。这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c75147529.retcon)
		e1:SetOperation(c75147529.retop)
		-- 作用：判断当前是否已经是对方回合的结束阶段，以决定返回场上的时点是本回合还是下个对方回合的结束阶段。
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
			-- 作用：将当前回合数记录在效果的Value中，用于后续判断是否在同一回合。
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(75147529,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(75147529,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
		end
		-- 作用：在全局环境中注册该延迟返回场上的效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 作用：延迟返回场上效果的发动条件：必须是对方回合的结束阶段，且不能是除外发生的当个回合。
function c75147529.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 作用：如果当前不是对方回合，或者当前回合数等于除外发生的回合数，则不满足返回条件。
	if Duel.GetTurnPlayer()~=1-tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(75147529)~=0
end
-- 作用：延迟返回场上效果的处理：将暂时除外的怪兽返回到场上。
function c75147529.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 作用：将之前被暂时除外的怪兽返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- 作用：效果②的发动准备（Target阶段）：检查并选择自身以外的自己场上1张卡作为对象，并设置送去墓地操作信息。
function c75147529.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 作用：在发动效果时，检查自己场上是否存在除这张卡以外的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,c) end
	-- 作用：向发动效果的玩家提示“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 作用：让玩家选择自身以外的自己场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 作用：设置效果处理信息，表示此效果将把选中的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 作用：效果②的效果处理（Operation阶段）：使这张卡的攻击力上升1000，那之后将作为对象的卡送去墓地。
function c75147529.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 作用：获取在发动时选择的作为对象的卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 作用：中断当前效果处理，使“攻击力上升”与“送去墓地”不视为同时处理（对应“那之后”）。
	Duel.BreakEffect()
	-- 作用：将作为对象的卡因效果原因送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
