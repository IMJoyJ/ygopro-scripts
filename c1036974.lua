--ミスフォーチュン
-- 效果：
-- 选择对方场上表侧表示存在的1只怪兽发动。给与对方基本分选择的怪兽的原本攻击力一半的伤害。使用这个效果的回合，自己的怪兽不能攻击。
function c1036974.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只怪兽发动。给与对方基本分选择的怪兽的原本攻击力一半的伤害。使用这个效果的回合，自己的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1036974.cost)
	e1:SetTarget(c1036974.target)
	e1:SetOperation(c1036974.activate)
	c:RegisterEffect(e1)
end
-- 检查本回合是否进行过攻击，并注册本回合不能进行攻击的效果
function c1036974.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己玩家在本回合是否进行过攻击宣言
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 选择对方场上表侧表示存在的1只怪兽发动。给与对方基本分选择的怪兽的原本攻击力一半的伤害。使用这个效果的回合，自己的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己玩家注册本回合不能进行攻击的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤对方场上表侧表示且原本攻击力大于0的怪兽
function c1036974.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- 以对方场上1只表侧表示且原本攻击力大于0的怪兽为对象发动，并设置给与对方伤害的操作信息
function c1036974.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c1036974.filter(chkc) end
	-- 检查对方场上是否存在可以作为效果对象的、原本攻击力大于0的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c1036974.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只原本攻击力大于0的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c1036974.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置给与对方相当于所选怪兽原本攻击力一半数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetBaseAttack()/2))
end
-- 给与对方作为对象的怪兽原本攻击力一半数值的伤害
function c1036974.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给与对方相当于作为对象的怪兽原本攻击力一半数值的伤害
		Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
