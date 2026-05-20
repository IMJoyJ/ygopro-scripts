--伝説の騎士 ヘルモス
-- 效果：
-- 这张卡不能通常召唤。「传说之心」的效果才能特殊召唤。
-- ①：这张卡特殊召唤成功时，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的魔法·陷阱卡除外。
-- ②：1回合1次，这张卡被选择作为攻击对象时，以自己墓地1只效果怪兽为对象才能发动。这张卡直到下次的自己回合的结束阶段当作和那只墓地的怪兽同名卡使用，得到相同效果。
function c84565800.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「传说之心」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的魔法·陷阱卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84565800,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c84565800.rmtg)
	e2:SetOperation(c84565800.rmop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡被选择作为攻击对象时，以自己墓地1只效果怪兽为对象才能发动。这张卡直到下次的自己回合的结束阶段当作和那只墓地的怪兽同名卡使用，得到相同效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84565800,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c84565800.cptg)
	e3:SetOperation(c84565800.cpop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且可以被除外的魔法·陷阱卡
function c84565800.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove() and c:IsFaceup()
end
-- 效果①的靶向/对象选择阶段，确认场上是否存在可除外的表侧表示魔陷，并进行取对象和设置操作信息
function c84565800.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c84565800.rmfilter(chkc) end
	-- 检查场上是否存在至少1张满足条件的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c84565800.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1张满足条件的表侧表示魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c84565800.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示该效果包含除外1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的处理阶段，将作为对象的表侧表示魔法·陷阱卡除外
function c84565800.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		-- 将目标卡片以表侧表示因效果除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤墓地中的效果怪兽
function c84565800.cpfilter(c)
	return c:IsType(TYPE_EFFECT)
end
-- 效果②的靶向/对象选择阶段，确认自己墓地是否存在效果怪兽，并进行取对象
function c84565800.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c84565800.cpfilter(chkc) end
	-- 检查自己墓地是否存在至少1只效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c84565800.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己墓地1只效果怪兽作为效果对象
	Duel.SelectTarget(tp,c84565800.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 效果②的处理阶段，使这张卡直到下次自己回合的结束阶段当作同名卡使用并获得相同效果
function c84565800.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的墓地效果怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		local code=tc:GetCode()
		-- 这张卡直到下次的自己回合的结束阶段当作和那只墓地的怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
end
