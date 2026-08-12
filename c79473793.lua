--青氷の白夜龍
-- 效果：
-- ①：这张卡为对象的魔法·陷阱卡发动时发动。那个发动无效并破坏。
-- ②：这张卡以外的自己的表侧表示怪兽被选择作为攻击对象时，把自己场上1张魔法·陷阱卡送去墓地才能发动。攻击对象转移为这张卡。
function c79473793.initial_effect(c)
	-- ①：这张卡为对象的魔法·陷阱卡发动时发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79473793,0))  --"无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c79473793.negcon)
	e1:SetTarget(c79473793.negtg)
	e1:SetOperation(c79473793.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己的表侧表示怪兽被选择作为攻击对象时，把自己场上1张魔法·陷阱卡送去墓地才能发动。攻击对象转移为这张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79473793,1))  --"改变攻击对象"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c79473793.cbcon)
	e2:SetCost(c79473793.cbcost)
	e2:SetTarget(c79473793.cbtg)
	e2:SetOperation(c79473793.cbop)
	c:RegisterEffect(e2)
end
-- 判定是否满足发动无效效果的条件：以这张卡为对象的魔法·陷阱卡的发动
function c79473793.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置发动无效与破坏效果的操作信息
function c79473793.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行发动无效并破坏的效果处理
function c79473793.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且该卡在场上存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
-- 判定是否满足转移攻击对象效果的条件：自己场上除这张卡以外的表侧表示怪兽被选择为攻击对象
function c79473793.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and c~=bt and bt:IsFaceup() and bt:GetControler()==c:GetControler()
end
-- 过滤条件：场上的魔法·陷阱卡，且能送去墓地
function c79473793.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 执行转移攻击对象效果的Cost处理：将自己场上1张魔法·陷阱卡送去墓地
function c79473793.cbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上是否存在可送去墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79473793.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张满足过滤条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c79473793.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为发动Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置转移攻击对象效果的目标检查
function c79473793.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认攻击怪兽的可攻击对象中是否包含这张卡
	if chk==0 then return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler()) end
end
-- 执行转移攻击对象效果的效果处理
function c79473793.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡是否仍受效果影响，且攻击怪兽不免疫此效果
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为这张卡
		Duel.ChangeAttackTarget(c)
	end
end
