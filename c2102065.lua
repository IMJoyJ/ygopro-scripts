--ブライニグル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只水属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
-- ②：这张卡被送去墓地的场合，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
function c2102065.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只水属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2102065,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,2102065)
	e1:SetTarget(c2102065.atktg1)
	e1:SetOperation(c2102065.atkop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2102065,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,2102065)
	e3:SetTarget(c2102065.atktg2)
	e3:SetOperation(c2102065.atkop2)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中攻击力大于0的水属性怪兽，作为效果①选择对象的候选集。
function c2102065.atkfilter1(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:GetAttack()>0
end
-- 效果①的取对象处理：在指定对象时验证对象位于自己墓地且为攻击力大于0的水属性怪兽；在发动条件检查时确认墓地存在满足条件的怪兽；提示玩家选择对象并从自己墓地选择1只作为对象。
function c2102065.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2102065.atkfilter1(chkc) end
	-- 效果①发动条件检查：确认自己墓地存在至少1只攻击力大于0的水属性怪兽，才允许发动。
	if chk==0 then return Duel.IsExistingTarget(c2102065.atkfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家正在为效果①选择对象，并显示“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只攻击力大于0的水属性怪兽，并将其登记为效果①的取对象。
	Duel.SelectTarget(tp,c2102065.atkfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 效果①处理：取得效果持有者与对象卡，若对象仍与效果关联且这张卡表侧表示，则使这张卡的攻击力上升对象当前攻击力的数值，直到回合结束时。
function c2102065.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果①发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己场上表侧表示的水属性怪兽，作为效果②选择对象的候选集。
function c2102065.atkfilter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的取对象处理：在指定对象时验证对象位于自己场上且为表侧表示的水属性怪兽；在发动条件检查时确认场上存在满足条件的怪兽；提示玩家选择对象并从自己场上选择1只作为对象。
function c2102065.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2102065.atkfilter2(chkc) end
	-- 效果②发动条件检查：确认自己场上存在至少1只表侧表示的水属性怪兽，才允许发动。
	if chk==0 then return Duel.IsExistingTarget(c2102065.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家正在为效果②选择对象，并显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的水属性怪兽，并将其登记为效果②的取对象。
	Duel.SelectTarget(tp,c2102065.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②处理：取得对象卡，若对象仍表侧表示且与效果关联，则使对象怪兽的攻击力上升1000，直到回合结束时。
function c2102065.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
