--ゴーストリック・サキュバス
-- 效果：
-- 2星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择持有场上的名字带有「鬼计」的怪兽的攻击力合计以下的攻击力的场上1只怪兽才能发动。选择的怪兽破坏，只要自己场上有名字带有「鬼计」的怪兽存在，那个怪兽卡区域不能使用。此外，自己场上有这张卡以外的名字带有「鬼计」的怪兽存在的场合，对方不能把这张卡作为攻击对象。
function c32224143.initial_effect(c)
	-- 为卡片添加等级为2、需要2只怪兽进行叠放的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择持有场上的名字带有「鬼计」的怪兽的攻击力合计以下的攻击力的场上1只怪兽才能发动。选择的怪兽破坏，只要自己场上有名字带有「鬼计」的怪兽存在，那个怪兽卡区域不能使用。此外，自己场上有这张卡以外的名字带有「鬼计」的怪兽存在的场合，对方不能把这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32224143,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c32224143.cost)
	e1:SetTarget(c32224143.target)
	e1:SetOperation(c32224143.operation)
	c:RegisterEffect(e1)
	-- 自己场上有这张卡以外的名字带有「鬼计」的怪兽存在的场合，对方不能把这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(c32224143.atkcon)
	-- 设置效果值为过滤函数aux.imval1，用于判断是否不能成为攻击对象
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
end
-- 支付效果的费用：从自己场上取除1个超量素材
function c32224143.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：返回场上正面表示的、名字带有「鬼计」的怪兽
function c32224143.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 过滤函数：返回场上正面表示的、攻击力不超过指定值的怪兽
function c32224143.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 选择目标：选择场上攻击力不超过名字带有「鬼计」的怪兽攻击力合计的1只怪兽
function c32224143.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上名字带有「鬼计」的怪兽组
	local cg=Duel.GetMatchingGroup(c32224143.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local atk=cg:GetSum(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32224143.filter(chkc,atk) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c32224143.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上攻击力不超过名字带有「鬼计」的怪兽攻击力合计的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c32224143.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	-- 设置操作信息：破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏目标怪兽并使该怪兽所在区域不能使用
function c32224143.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽的位置转换为全局位掩码值
	local val=aux.SequenceToGlobal(tc:GetControler(),LOCATION_MZONE,tc:GetSequence())
	-- 判断目标怪兽是否有效且正面表示并成功破坏
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 创建并注册无效区域效果，使目标怪兽所在区域不能使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetCondition(c32224143.discon)
		e1:SetValue(val)
		-- 将无效区域效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 无效区域效果的触发条件函数：当自己场上存在名字带有「鬼计」的怪兽时生效
function c32224143.discon(e)
	-- 检查自己场上是否存在名字带有「鬼计」的怪兽
	if Duel.IsExistingMatchingCard(c32224143.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) then
		return true
	end
	e:Reset()
	return false
end
-- 判断是否不能成为攻击对象的条件函数：当自己场上存在名字带有「鬼计」的怪兽时生效
function c32224143.atkcon(e)
	-- 检查自己场上是否存在名字带有「鬼计」的怪兽
	return Duel.IsExistingMatchingCard(c32224143.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
