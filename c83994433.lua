--閃珖竜 スターダスト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，选择自己场上表侧表示存在的1张卡才能发动。选择的卡在这个回合只有1次不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。
function c83994433.initial_effect(c)
	-- 为卡片添加同调召唤手续（调整＋调整以外的怪兽1只以上）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，选择自己场上表侧表示存在的1张卡才能发动。选择的卡在这个回合只有1次不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83994433,0))  --"破坏耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83994433.target)
	e1:SetOperation(c83994433.operation)
	c:RegisterEffect(e1)
end
-- 过滤表侧表示卡片的条件函数
function c83994433.filter(c)
	return c:IsFaceup()
end
-- 效果发动的目标选择与合法性检测函数
function c83994433.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c83994433.filter(chkc) end
	-- 在发动效果的准备阶段，检测自己场上是否存在至少1张表侧表示的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c83994433.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1张表侧表示的卡作为效果对象
	Duel.SelectTarget(tp,c83994433.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 效果处理函数，使选择的对象在这个回合获得1次不会被战斗及卡的效果破坏的耐性
function c83994433.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的卡在这个回合只有1次不会被战斗以及卡的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(c83994433.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判定破坏原因为战斗或卡的效果的条件函数
function c83994433.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
