--F.A.ダウンフォース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升2星。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升2星。这个效果在这张卡送去墓地的回合不能发动。
function c66322203.initial_effect(c)
	-- ①：以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升2星。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66322203)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c66322203.target)
	e1:SetOperation(c66322203.operation)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「方程式运动员」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升2星。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,66322204)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果的发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c66322203.target)
	e2:SetOperation(c66322203.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、等级在1以上且属于「方程式运动员」系列的怪兽
function c66322203.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:IsLevelAbove(1)
end
-- 效果的发动准备：检查并选择自己场上1只「方程式运动员」怪兽作为对象
function c66322203.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66322203.filter(chkc) end
	-- 在发动时，检查自己场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c66322203.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c66322203.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果的处理：使作为对象的怪兽等级直到回合结束时上升2星
function c66322203.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时上升2星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2)
		tc:RegisterEffect(e1)
	end
end
