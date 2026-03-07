--ファントム・オブ・カオス
-- 效果：
-- ①：1回合1次，以自己墓地1只效果怪兽为对象才能发动。那只怪兽除外，这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同的原本攻击力和效果。
-- ②：这张卡的战斗发生的对对方的战斗伤害变成0。
local s,id,o=GetID()
-- 创建效果①，用于发动时除外墓地一只效果怪兽并复制其卡名和攻击力，且该效果只能在主要怪兽区发动，具有取对象效果且每回合只能发动一次。
function c30312361.initial_effect(c)
	-- ①：1回合1次，以自己墓地1只效果怪兽为对象才能发动。那只怪兽除外，这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同的原本攻击力和效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30312361,0))  --"复制效果"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c30312361.cost)
	e1:SetTarget(c30312361.target)
	e1:SetOperation(c30312361.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗发生的对对方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
end
-- 设置效果①的发动费用，确保每回合只能发动一次。
function c30312361.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(30312361)==0 end
	e:GetHandler():RegisterFlagEffect(30312361,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 定义过滤器，用于筛选墓地中的效果怪兽。
function c30312361.filter(c)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToRemove()
end
-- 设置效果①的目标选择逻辑，确保选择的是己方墓地中的效果怪兽。
function c30312361.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30312361.filter(chkc) end
	-- 检查是否满足发动效果①的条件，即己方墓地是否存在效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30312361.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽并设置操作信息。
	local g=Duel.SelectTarget(tp,c30312361.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表明将要除外目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 处理效果①的发动效果，将目标怪兽除外并复制其卡名和攻击力。
function c30312361.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效，且自身是否处于正面表示状态，以确保效果正常处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==1 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetOriginalCode()
		local ba=tc:GetBaseAttack()
		-- 调用aux.BecomeOriginalCode函数，使自身卡名变为目标怪兽的原始卡号。
		local e1=aux.BecomeOriginalCode(c,tc)
		-- 创建一个临时效果，用于在结束阶段前将自身攻击力设置为与目标怪兽相同。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e2:SetValue(ba)
		c:RegisterEffect(e2)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 创建一个持续到结束阶段的效果，用于在结束阶段重置自身效果。
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(1162)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetLabel(cid)
		e3:SetLabelObject(e2)
		e3:SetOperation(s.rstop)
		c:RegisterEffect(e3)
	end
end
-- 处理结束阶段时的效果重置逻辑，包括重置复制效果和临时攻击力效果。
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e2=e:GetLabelObject()
	local e1=e2:GetLabelObject()
	e1:Reset()
	e2:Reset()
	-- 显示被选为对象的动画效果。
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家效果已发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
