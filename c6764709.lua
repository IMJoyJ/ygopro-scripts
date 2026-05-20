--F.A.ダークネスマスター
-- 效果：
-- 这张卡不能通常召唤。场上有7星以上的「方程式运动员」怪兽存在，自己的怪兽区域没有「方程式运动员 暗冥赛道名将」存在的场合可以特殊召唤。
-- ①：这张卡的攻击力上升这张卡的等级×300。
-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ③：1回合1次，以场上1张卡为对象才能发动。这张卡的等级下降3星，那张卡破坏。
function c6764709.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。场上有7星以上的「方程式运动员」怪兽存在，自己的怪兽区域没有「方程式运动员 暗冥赛道名将」存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c6764709.spcon)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升这张卡的等级×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c6764709.atkval)
	c:RegisterEffect(e2)
	-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(6764709,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(c6764709.lvcon)
	e4:SetOperation(c6764709.lvop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，以场上1张卡为对象才能发动。这张卡的等级下降3星，那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(6764709,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(c6764709.rdtg)
	e5:SetOperation(c6764709.rdop)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示的「方程式运动员 暗冥赛道名将」
function c6764709.spfilter1(c)
	return c:IsFaceup() and c:IsCode(6764709)
end
-- 过滤条件：场上表侧表示的7星以上的「方程式运动员」怪兽
function c6764709.spfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:IsLevelAbove(7)
end
-- 特殊召唤规则的条件判断
function c6764709.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 如果自己场上已存在「方程式运动员 暗冥赛道名将」，则不能特殊召唤
		or Duel.IsExistingMatchingCard(c6764709.spfilter1,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查场上是否存在7星以上的「方程式运动员」怪兽
	return Duel.IsExistingMatchingCard(c6764709.spfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 计算并返回攻击力上升值（等级×300）
function c6764709.atkval(e,c)
	return c:GetLevel()*300
end
-- 检查发动的效果是否为「方程式运动员」魔法·陷阱卡的效果
function c6764709.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- 等级上升效果的处理：使这张卡的等级上升1星
function c6764709.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_LEVEL)
		e4:SetValue(1)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e4)
	end
end
-- 破坏效果的靶向与发动条件判定（自身等级需在4星以上）
function c6764709.rdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and e:GetHandler():IsLevelAbove(4) end
	-- 给玩家发送提示信息：选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作的信息，包含目标卡片和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行：降低自身等级并破坏目标卡片
function c6764709.rdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelBelow(3) then return end
	-- 这张卡的等级下降3星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-3)
	c:RegisterEffect(e1)
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
