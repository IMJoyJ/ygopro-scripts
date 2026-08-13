--BF－アンカー
-- 效果：
-- 把1只名字带有「黑羽」的怪兽解放，选择自己场上表侧表示存在的1只同调怪兽发动。选择的怪兽的攻击力直到结束阶段时上升为把这张卡发动而解放的怪兽的攻击力数值。
function c25435080.initial_effect(c)
	-- 把1只名字带有「黑羽」的怪兽解放，选择自己场上表侧表示存在的1只同调怪兽发动。选择的怪兽的攻击力直到结束阶段时上升为把这张卡发动而解放的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤限制：只能在伤害计算前且非伤害步骤时发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c25435080.cost)
	e1:SetTarget(c25435080.target)
	e1:SetOperation(c25435080.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
-- 定义解放候选的过滤函数：必须是名字带有「黑羽」的怪兽，且自己场上存在除它以外可选的表侧同调怪兽。
function c25435080.cfilter(c,tp)
	-- 判断候选怪兽是黑羽字段，并且自己场上有其他可选择的同调怪兽（排除c），确保解放后仍有对象可选。
	return c:IsSetCard(0x33) and Duel.IsExistingTarget(c25435080.tfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 定义选择对象的过滤函数：怪兽需表侧表示且为同调怪兽。
function c25435080.tfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 代价函数：实际解放操作延迟到target处理，此处仅用标签标记代价检查已完成，返回true表示满足代价条件。
function c25435080.cost(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	return true
end
-- 目标选择阶段：先检查是否存在可解放的黑羽怪兽及可选对象；若存在则选择解放怪兽（记录攻击力并解放），再选择1只己方表侧同调怪兽作为效果对象。
function c25435080.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c25435080.tfilter(chkc) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在至少1只满足“黑羽字段且另有可选同调对象”的怪兽可作为解放代价。
		return Duel.CheckReleaseGroup(tp,c25435080.cfilter,1,nil,tp)
	end
	-- 从自己场上选择1只满足条件的黑羽怪兽作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,c25435080.cfilter,1,1,nil,tp)
	e:SetLabel(rg:GetFirst():GetAttack())
	-- 将选中的黑羽怪兽解放（作为效果发动的代价）。
	Duel.Release(rg,REASON_COST)
	-- 显示“请选择表侧表示的卡”的提示文字，用于目标选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上表侧表示存在的1只同调怪兽作为效果的对象。
	Duel.SelectTarget(tp,c25435080.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍表侧且与效果关联，则赋予其攻击力上升效果，上升值为解放怪兽的攻击力，持续到结束阶段。
function c25435080.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力直到结束阶段时上升为把这张卡发动而解放的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
