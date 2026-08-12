--エヴォリューション・バースト
-- 效果：
-- 自己场上有「电子龙」表侧表示存在的场合才能发动。对方场上1张卡破坏。这张卡发动的回合「电子龙」不能攻击。
function c52875873.initial_effect(c)
	-- 创建效果e1，设置为魔陷发动效果，具有取对象属性，可以自由连锁发动，条件为己方场上存在电子龙，费用为支付一次，目标为对方场上任意一张卡，效果为破坏对方场上一张卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c52875873.condition)
	e1:SetCost(c52875873.cost)
	e1:SetTarget(c52875873.target)
	e1:SetOperation(c52875873.activate)
	c:RegisterEffect(e1)
	-- 设置一个代号为52875873的计数器，类型为攻击次数，过滤函数为非电子龙的卡片
	Duel.AddCustomActivityCounter(52875873,ACTIVITY_ATTACK,c52875873.counterfilter)
end
-- 计数器过滤函数，返回值为true时该卡片不计入攻击次数计数器
function c52875873.counterfilter(c)
	return not c:IsCode(70095154)
end
-- 判断卡片是否表侧表示且为电子龙（卡号70095154）
function c52875873.cfilter(c)
	return c:IsFaceup() and c:IsCode(70095154)
end
-- 效果条件函数，检查己方场上是否存在一张表侧表示的电子龙
function c52875873.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少一张表侧表示的电子龙
	return Duel.IsExistingMatchingCard(c52875873.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 费用函数，检查本回合是否未对电子龙进行过攻击，若未攻击则创建一个使电子龙不能攻击的效果并注册
function c52875873.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未对电子龙进行过攻击
	if chk==0 then return Duel.GetCustomActivityCount(52875873,tp,ACTIVITY_ATTACK)==0 end
	-- 创建一个使电子龙不能攻击的效果，该效果为永续Field效果，无视免疫，作用范围为主怪区，结束阶段重置，并注册给玩家
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果的目标为卡号为70095154（电子龙）的卡片
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,70095154))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 目标选择函数，检查目标是否为对方场上的卡
function c52875873.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查己方场上是否存在至少一张对方场上的卡作为目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏效果，目标为所选的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 发动函数，若目标卡存在则将其破坏
function c52875873.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
