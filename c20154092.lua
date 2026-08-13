--先史遺産カブレラの投石機
-- 效果：
-- 1回合1次，把这张卡以外的自己场上1只名字带有「先史遗产」的怪兽解放，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时变成0。
function c20154092.initial_effect(c)
	-- 对应效果原文：1回合1次，把这张卡以外的自己场上1只名字带有「先史遗产」的怪兽解放，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20154092,0))  --"攻击变成0"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c20154092.cost)
	e2:SetTarget(c20154092.target)
	e2:SetOperation(c20154092.operation)
	c:RegisterEffect(e2)
end
-- 定义代价函数：检查并执行‘把这张卡以外的自己场上1只名字带有「先史遗产」的怪兽解放’这一代价。
function c20154092.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，检查自己场上是否存在1只卡名含有「先史遗产」的这张卡以外的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x70) end
	-- 选择自己场上1只卡名含有「先史遗产」的这张卡以外的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x70)
	-- 将所选怪兽解放，作为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义发动目标选择函数：选择对方场上表侧表示存在的1只怪兽作为效果对象。
function c20154092.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在目标检测阶段，确认对方场上有1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示‘请选择表侧表示的卡’的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际选择对方场上1只表侧表示怪兽作为对象，并与此连锁建立关联。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理函数：将对象怪兽的攻击力直到结束阶段时变成0。
function c20154092.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的这只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 对应效果原文：‘选择的怪兽的攻击力直到结束阶段时变成0。’——为对象怪兽添加一个永续效果：将其攻击力最终数值固定为0，并在结束阶段重置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
