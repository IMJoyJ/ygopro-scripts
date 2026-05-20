--A・O・J アンリミッター
-- 效果：
-- 把这张卡解放发动。自己场上表侧表示存在的1只名字带有「正义盟军」的怪兽的原本攻击力直到这个回合的结束阶段时变成2倍。
function c82377606.initial_effect(c)
	-- 把这张卡解放发动。自己场上表侧表示存在的1只名字带有「正义盟军」的怪兽的原本攻击力直到这个回合的结束阶段时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82377606,0))  --"原本攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c82377606.atkcost)
	e1:SetTarget(c82377606.atktg)
	e1:SetOperation(c82377606.atkop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查自身是否可以解放，并在发动时将自身解放
function c82377606.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的名字带有「正义盟军」的怪兽
function c82377606.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1)
end
-- 定义效果的目标：确认是否存在符合条件的对象并进行选择
function c82377606.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c82377606.filter(chkc) end
	-- 在效果发动阶段，检查自己场上是否存在符合条件的名字带有「正义盟军」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c82377606.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的名字带有「正义盟军」的怪兽作为效果对象
	Duel.SelectTarget(tp,c82377606.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果的处理：使选择的对象的原本攻击力直到回合结束阶段变成2倍
function c82377606.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local batk=tc:GetBaseAttack()
		-- 原本攻击力直到这个回合的结束阶段时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(batk*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
