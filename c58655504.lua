--ノーマテリア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上没有卡存在，对方对怪兽的特殊召唤成功的场合，把这张卡从手卡丢弃，以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽不能解放，也不能作为融合·同调·超量·连接召唤的素材。
function c58655504.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上没有卡存在，对方对怪兽的特殊召唤成功的场合，把这张卡从手卡丢弃，以对方场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽不能解放，也不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,58655504)
	e1:SetCondition(c58655504.condition)
	e1:SetCost(c58655504.cost)
	e1:SetTarget(c58655504.target)
	e1:SetOperation(c58655504.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方特殊召唤的怪兽
function c58655504.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：对方对怪兽的特殊召唤成功
function c58655504.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c58655504.cfilter,1,nil,tp)
end
-- 发动代价：把这张卡从手卡丢弃
function c58655504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果的目标选择：确认自己场上没有卡存在，并选择对方场上1只表侧表示怪兽
function c58655504.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查自己场上是否存在卡片（必须没有卡存在）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
		-- 检查对方场上是否存在可作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使目标怪兽在这个回合不能解放，且不能作为融合、同调、超量、连接召唤的素材
function c58655504.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取已选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 这个回合，那只怪兽不能解放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(c58655504.fuslimit)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e5)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e6)
	end
end
-- 限制该怪兽在进行融合召唤时不能作为素材
function c58655504.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
