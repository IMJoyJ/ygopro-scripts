--魔轟神ミーズトージ
-- 效果：
-- 把这张卡从手卡送去墓地，选择自己场上表侧表示存在的1只名字带有「魔轰神」的怪兽发动。选择怪兽只要在场上表侧表示存在当作调整使用。
function c8316661.initial_effect(c)
	-- 把这张卡从手卡送去墓地，选择自己场上表侧表示存在的1只名字带有「魔轰神」的怪兽发动。选择怪兽只要在场上表侧表示存在当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8316661,0))  --"选择一只怪兽当调整使用"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c8316661.cost)
	e1:SetTarget(c8316661.tg)
	e1:SetOperation(c8316661.op)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查并执行将自身从手牌送去墓地的操作
function c8316661.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示、名字带有「魔轰神」且不是调整的怪兽
function c8316661.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x35) and not c:IsType(TYPE_TUNER)
end
-- 定义效果的目标：选择自己场上1只表侧表示的「魔轰神」怪兽作为对象
function c8316661.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c8316661.filter(chkc) end
	-- 在发动时，检查自己场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c8316661.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择并锁定1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c8316661.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果的处理：使选择的对象怪兽当作调整使用
function c8316661.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择怪兽只要在场上表侧表示存在当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
