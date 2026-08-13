--霊子もつれ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
function c28234578.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28234578+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28234578.target)
	e1:SetOperation(c28234578.activate)
	c:RegisterEffect(e1)
end
-- 定义对象怪兽的过滤条件：必须是对方场上表侧表示且可以被除外的怪兽。
function c28234578.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果发动时的目标选择流程：先确认存在合法对象，再提示玩家选择1只对方场上的表侧表示怪兽，并设置除外相关的操作信息。
function c28234578.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c28234578.filter(chkc) end
	-- 在发动合法性检查（chk==0）时，确认对方场上是否存在至少1只满足过滤条件的表侧表示怪兽，作为可否发动的判定。
	if chk==0 then return Duel.IsExistingTarget(c28234578.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择提示，提示内容为“请选择要除外的卡”并关联到HINTMSG_REMOVE。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从对方场上表侧表示且可除外的怪兽中选择1只，并将其设置为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,c28234578.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，声明本次效果涉及除外，对象为g且数量为1，使其他卡牌能正确响应该效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理阶段：取得对象怪兽，若其仍与效果关联，则以效果原因将其暂时除外，并注册一个在结束阶段将其返回场上的诱发效果。
function c28234578.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与此效果关联，并尝试以效果原因将其暂时除外；若除外成功则继续设置返回效果。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 那只怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c28234578.retop)
		-- 将新建的结束阶段诱发效果注册到当前玩家（tp）身上，使该效果在结束阶段时触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段返回效果的操作函数：将之前暂时除外的对象怪兽返回场上。
function c28234578.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的对象怪兽通过Duel.ReturnToField返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
