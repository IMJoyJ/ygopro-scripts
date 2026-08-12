--武神器－サグサ
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择自己场上1只名字带有「武神」的兽战士族怪兽才能发动。选择的怪兽在这个回合只有1次不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。「武神器-品」的效果1回合只能使用1次。
function c59251766.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，选择自己场上1只名字带有「武神」的兽战士族怪兽才能发动。选择的怪兽在这个回合只有1次不会被战斗以及卡的效果破坏。这个效果在对方回合也能发动。「武神器-品」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59251766,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,59251766)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c59251766.target)
	e1:SetOperation(c59251766.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「武神」的兽战士族怪兽
function c59251766.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 效果发动的目标选择与合法性检测
function c59251766.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c59251766.filter(chkc) end
	-- 检查自己场上是否存在满足过滤条件的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c59251766.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足过滤条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c59251766.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽在这个回合获得1次不被战斗或效果破坏的耐性
function c59251766.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽在这个回合只有1次不会被战斗以及卡的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(c59251766.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 破坏耐性的判定条件：因战斗或卡的效果导致的破坏
function c59251766.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
