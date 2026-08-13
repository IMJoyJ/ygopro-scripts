--ワーム・ホール
-- 效果：
-- 选自己场上的1只怪兽，在自己的下次的准备阶段之前除外。除外的时候，被选择的怪兽的怪兽区的位置不能使用。
function c22959079.initial_effect(c)
	-- 选自己场上的1只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22959079.target)
	e1:SetOperation(c22959079.operation)
	c:RegisterEffect(e1)
end
-- 定义选择过滤器：判定怪兽是否可以被除外（满足除外条件）。
function c22959079.filter(c)
	return c:IsAbleToRemove()
end
-- 发动时的目标选择函数：检查自己场上是否存在可除外的怪兽，选择1只作为对象，并设置除外相关操作信息。
function c22959079.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c22959079.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在至少1只可以除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22959079.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足条件的怪兽作为效果对象，并自动记录为连锁对象。
	local g=Duel.SelectTarget(tp,c22959079.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次连锁将除外所选择的1只怪兽，供其他卡连锁时检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数：将被选择怪兽暂时除外，并注册后续的返回效果和封锁原怪兽区位置的效果。
function c22959079.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽当前所在怪兽区格子的序号转换为全局区域掩码值，用于后续无效该位置。
	local val=aux.SequenceToGlobal(tc:GetControler(),LOCATION_MZONE,tc:GetSequence())
	-- 确认目标仍与效果关联，并以效果、暂时除外的方式将其除外；若除外成功则继续执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 在自己的下次的准备阶段之前除外
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c22959079.rtcon)
		e1:SetOperation(c22959079.retop)
		-- 注册准备阶段返回效果：在满足条件时于自己的下次准备阶段将被除外的怪兽返回场上。
		Duel.RegisterEffect(e1,tp)
		-- 除外的时候，被选择的怪兽的怪兽区的位置不能使用。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE_FIELD)
		e2:SetLabelObject(tc)
		e2:SetCondition(c22959079.discon)
		e2:SetValue(val)
		-- 注册无效区域效果：使目标怪兽原本所在的怪兽区位置不能使用，直到怪兽返回场上。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 返回效果的条件函数：仅当当前回合玩家是效果所有者（即发动者）时，才允许在准备阶段返回怪兽。
function c22959079.rtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否与效果所有者相同，以限定“自己的下次准备阶段”。
	return tp==Duel.GetTurnPlayer()
end
-- 返回操作函数：将被除外的目标怪兽返回场上。
function c22959079.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标记的怪兽（暂时除外的目标）返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- 无效区域效果的条件函数：若目标怪兽仍在除外区则保持区域无效；若已不在除外区则重置该效果并停止无效。
function c22959079.discon(e,c)
	if e:GetLabelObject():IsLocation(LOCATION_REMOVED) then
		return true
	else
		e:Reset()
		return false
	end
end
