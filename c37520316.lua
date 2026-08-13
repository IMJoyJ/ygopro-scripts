--精神操作
-- 效果：
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能攻击宣言，不能解放。
function c37520316.initial_effect(c)
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽不能攻击宣言，不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37520316.target)
	e1:SetOperation(c37520316.activate)
	c:RegisterEffect(e1)
end
-- 取对象效果的目标判定函数：效果发动时检查并选择对方场上1只怪兽作为对象，要求该怪兽位于主要怪兽区且控制权可以被改变；选择后登记为当前连锁的对象，并设置变更控制权的操作信息。
function c37520316.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 发动合法性检查：确认对方场上是否存在至少1只满足‘控制权可变更’且可被选择的怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选卡提示信息，提示内容为‘请选择要改变控制权的怪兽’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让操作玩家从对方场上选择1只满足条件的怪兽作为效果对象，同时通过SelectTarget将该卡登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记连锁处理信息：效果分类为‘变更控制权’，处理对象为已选择的1只怪兽，供后续规则判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：取得对象怪兽并尝试获得其控制权直到结束阶段；若转移成功，则对那只怪兽附加‘不能攻击宣言、不能解放’的限制效果，这些限制在结束阶段或卡片离场等标准重置时机消失。
function c37520316.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 验证券对象怪兽仍与当前效果相关（未被离场或效果失效），并尝试将其控制权转移给自己直到结束阶段；控制权转移成功时才继续附加后续限制效果。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		-- 这个效果得到控制权的怪兽不能解放（对应‘不能作为上级召唤的祭品’的限制）。
		local e1=Effect.CreateEffect(c)
		local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(reset)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 这个效果得到控制权的怪兽不能解放（对应‘不能作为上级召唤以外的祭品’的限制）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2:SetReset(reset)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		-- 这个效果得到控制权的怪兽不能攻击宣言。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(reset)
		tc:RegisterEffect(e3)
	end
end
