--ゴーストリック・サキュバス
-- 效果：
-- 2星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择持有场上的名字带有「鬼计」的怪兽的攻击力合计以下的攻击力的场上1只怪兽才能发动。选择的怪兽破坏，只要自己场上有名字带有「鬼计」的怪兽存在，那个怪兽卡区域不能使用。此外，自己场上有这张卡以外的名字带有「鬼计」的怪兽存在的场合，对方不能把这张卡作为攻击对象。
function c32224143.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用等级2的怪兽2只为素材进行XYZ召唤，对应原效果中的‘2星怪兽×2’。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择持有场上的名字带有「鬼计」的怪兽的攻击力合计以下的攻击力的场上1只怪兽才能发动。选择的怪兽破坏，只要自己场上有名字带有「鬼计」的怪兽存在，那个怪兽卡区域不能使用。
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
	-- 此外，自己场上有这张卡以外的名字带有「鬼计」的怪兽存在的场合，对方不能把这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(c32224143.atkcon)
	-- 设置该‘不能成为攻击对象’效果的判定值aux.imval1，使对方怪兽在攻击宣言前检查这张卡是否对该效果免疫；若免疫则不受限制，否则不能选择为攻击对象。
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
end
-- 发动效果时的代价处理：先确认这张卡至少有1个超量素材可移除，然后实际取除1个超量素材作为发动代价。
function c32224143.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义‘鬼计’怪兽过滤器：表侧表示且卡名属于‘鬼计’字段（0x8d）的怪兽。
function c32224143.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 定义破坏对象过滤器：场上表侧表示且攻击力不高于指定攻击力合计值atk的怪兽。
function c32224143.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果发动时的目标选择处理：计算场上表侧‘鬼计’怪兽的攻击力合计，检查是否存在攻击力在该合计以下的表侧怪兽；若存在则选择1只作为对象，并设置破坏的操作信息。
function c32224143.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上所有表侧表示的名字带有‘鬼计’的怪兽（不区分敌我），用于计算攻击力合计值。
	local cg=Duel.GetMatchingGroup(c32224143.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local atk=cg:GetSum(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32224143.filter(chkc,atk) end
	-- 发动合法性检查：确认场上存在至少1只攻击力在‘鬼计’攻击力合计以下的表侧怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c32224143.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 向玩家显示选择提示，提示内容为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只满足条件的表侧怪兽作为效果对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c32224143.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	-- 为当前连锁登记‘破坏1张卡’的操作信息，供相关效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象怪兽，计算其所在怪兽区域的格子位置；若对象仍与效果关联且表侧表示，则将其破坏；破坏成功后，在原本区域设置一个持续无效区域的效果，只要自己场上有‘鬼计’怪兽存在，那个怪兽卡区域不能使用。
function c32224143.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽，即要被破坏的那只怪兽。
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽所在的控制者、怪兽区域和格子序号转换为全局区域掩码，用于精确指定要无效的格子。
	local val=aux.SequenceToGlobal(tc:GetControler(),LOCATION_MZONE,tc:GetSequence())
	-- 判断对象怪兽是否仍与此效果相关、是否表侧表示，并尝试以效果将其破坏；只有破坏成功（返回非0）才继续执行区域无效处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 选择的怪兽破坏，只要自己场上有名字带有「鬼计」的怪兽存在，那个怪兽卡区域不能使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetCondition(c32224143.discon)
		e1:SetValue(val)
		-- 将区域无效效果注册到当前玩家的场上，使其生效并持续接受条件检测。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义区域无效效果的持续条件：只要自己场上有表侧表示的名字带有‘鬼计’的怪兽存在，就保持该区域无效；若条件不再满足则自我重置，解除无效。
function c32224143.discon(e)
	-- 检查自己怪兽区域是否存在表侧表示的名字带有‘鬼计’的怪兽，以决定是否继续维持怪兽卡区域不能使用的封印效果。
	if Duel.IsExistingMatchingCard(c32224143.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) then
		return true
	end
	e:Reset()
	return false
end
-- 定义‘这张卡不能成为攻击对象’的效果条件：自己场上有这张卡以外的表侧表示的‘鬼计’怪兽存在。
function c32224143.atkcon(e)
	-- 检查自己场上是否存在这张卡以外的表侧表示的‘鬼计’怪兽，若存在则对方不能把这张卡选为攻击对象。
	return Duel.IsExistingMatchingCard(c32224143.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
