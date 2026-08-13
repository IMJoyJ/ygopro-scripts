--DDD死偉王ヘル・アーマゲドン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
-- 【怪兽效果】
-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的原本攻击力数值。这个效果发动的回合，这张卡不能直接攻击。
-- ②：这张卡不会被不以这张卡为对象的魔法·陷阱卡的效果破坏。
function c47198668.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性，使其可以作为灵摆卡放在灵摆区并进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c47198668.atktg1)
	e2:SetOperation(c47198668.atkop1)
	c:RegisterEffect(e2)
	-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合，以那1只怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的原本攻击力数值。这个效果发动的回合，这张卡不能直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1)
	e3:SetCost(c47198668.atkcost)
	e3:SetTarget(c47198668.atktg2)
	e3:SetOperation(c47198668.atkop2)
	c:RegisterEffect(e3)
	-- ②：这张卡不会被不以这张卡为对象的魔法·陷阱卡的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c47198668.efilter)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断卡是否为表侧表示且属于「DD」字段（0xaf）。
function c47198668.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 灵摆效果的发动条件与对象选择：在发动时检查自己场上是否存在表侧表示的DD怪兽，若存在则从中选择1只作为对象；若在连锁处理中检查对象合法性，则验证指定对象是否在自己怪兽区且符合条件。
function c47198668.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47198668.filter1(chkc) end
	-- 发动时（chk==0）检查自己怪兽区是否存在至少1只满足条件的表侧DD怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingTarget(c47198668.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送选择提示消息，提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己怪兽区选择1只表侧表示的DD怪兽，并将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,c47198668.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍为表侧表示且与本效果关联，则赋予其攻击力上升800的效果，持续到回合结束。
function c47198668.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果连锁中选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：判断被破坏的怪兽是否满足发动条件——因战斗或效果破坏、是怪兽、破坏前在我方怪兽区且由我方控制、现在在墓地或除外区，并且能被本次效果取为对象。
function c47198668.filter2(c,e,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
end
-- 发动代价：若此卡本回合已经直接攻击过则不能发动；否则给此卡附加本回合不能直接攻击的誓约效果作为发动代价。
function c47198668.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsDirectAttacked() end
	-- 这个效果发动的回合，这张卡不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 诱发效果的发动条件与对象选择：当自己场上的怪兽被战斗或效果破坏时，从这些被破坏的怪兽中筛选出满足条件的1只作为对象（需在墓地或除外区且能成为效果对象）。
function c47198668.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c47198668.filter2(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c47198668.filter2,1,nil,e,tp) end
	-- 发送选择提示消息，提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c47198668.filter2,1,1,nil,e,tp)
	-- 将选择的对象卡设为当前连锁的效果对象，使该卡与效果建立关联。
	Duel.SetTargetCard(g)
end
-- 效果处理：若此卡仍表侧表示且与本效果关联、对象怪兽也仍与本效果关联，则将此卡攻击力上升对象怪兽的原本攻击力数值，持续到回合结束。
function c47198668.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果连锁中选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升作为对象的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 免疫破坏判定：仅当效果为魔法·陷阱卡效果时考虑；若该效果不取对象，或取对象但对象不包含此卡，则此卡免疫该效果破坏；若取对象且对象包含此卡，则不免疫。
function c47198668.efilter(e,re,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁处理中效果的对象卡组，用于判断取对象效果是否以这张卡为对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
