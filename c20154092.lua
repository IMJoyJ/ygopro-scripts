--先史遺産カブレラの投石機
-- 效果：
-- 1回合1次，把这张卡以外的自己场上1只名字带有「先史遗产」的怪兽解放，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时变成0。
function c20154092.initial_effect(c)
	-- 1回合1次，把这张卡以外的自己场上1只名字带有「先史遗产」的怪兽解放，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时变成0。
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
-- 检查并选择1只自己场上的「先史遗产」怪兽进行解放作为效果的代价
function c20154092.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x70) end
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x70)
	-- 将选中的怪兽从场上解放，作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 选择对方场上1只表侧表示的怪兽作为效果对象
function c20154092.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上的1只表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将选择的怪兽攻击力变为0直到结束阶段
function c20154092.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力直到结束阶段时变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
