--ミスフォーチュン
-- 效果：
-- 选择对方场上表侧表示存在的1只怪兽发动。给与对方基本分选择的怪兽的原本攻击力一半的伤害。使用这个效果的回合，自己的怪兽不能攻击。
function c1036974.initial_effect(c)
	-- 创建效果，设置效果类型为启动效果，设置属性为卡片对象效果，设置代码为自由连锁，设置费用为c1036974.cost，设置目标为c1036974.target，设置发动为c1036974.activate，将效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1036974.cost)
	e1:SetTarget(c1036974.target)
	e1:SetOperation(c1036974.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的费用函数。
function c1036974.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为0，如果是，则返回玩家tp进行攻击的次数是否为0。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 创建效果，设置效果类型为场地效果，设置代码为不能攻击，设置属性为忽略免疫+誓约，设置目标范围为怪兽区，设置重置为阶段结束+结束阶段，将效果注册到玩家tp。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp。
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，用于筛选目标卡片。
function c1036974.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- 定义目标选择函数。
function c1036974.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c1036974.filter(chkc) end
	-- 检查是否为0，如果是，则返回是否存在满足c1036974.filter的卡片，玩家tp，0，怪兽区，1，nil。
	if chk==0 then return Duel.IsExistingTarget(c1036974.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家tp发送提示信息，提示内容为表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标卡片，玩家tp，c1036974.filter，玩家tp，0，怪兽区，1，1，nil。
	local g=Duel.SelectTarget(tp,c1036974.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的连锁的操作信息，0，伤害效果，nil，0，1-tp，g:GetFirst():GetBaseAttack()/2的向下取整。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetBaseAttack()/2))
end
-- 定义效果的发动函数。
function c1036974.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 如果目标卡片是表侧表示且与效果相关，则对1-tp玩家造成目标卡片原本攻击力一半的伤害，伤害原因是效果。
		Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
