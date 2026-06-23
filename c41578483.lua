--ミレニアム・アイズ・サクリファイス
-- 效果：
-- 「纳祭之魔」＋效果怪兽
-- ①：1回合1次，对方怪兽的效果发动时，以对方的场上·墓地1只效果怪兽为对象才能发动。那只对方的效果怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
-- ③：原本卡名和这张卡的效果装备的怪兽相同的怪兽不能攻击，那个效果无效化。
function c41578483.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为64631466的1只效果怪兽和1只满足类型为效果怪兽条件的怪兽作为融合素材进行融合召唤
	aux.AddFusionProcCodeFun(c,64631466,aux.FilterBoolFunction(Card.IsFusionType,TYPE_EFFECT),1,true,true)
	-- ①：1回合1次，对方怪兽的效果发动时，以对方的场上·墓地1只效果怪兽为对象才能发动。那只对方的效果怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41578483,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetCondition(c41578483.eqcon)
	e1:SetTarget(c41578483.eqtg)
	e1:SetOperation(c41578483.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c41578483.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c41578483.defval)
	c:RegisterEffect(e3)
	-- ③：原本卡名和这张卡的效果装备的怪兽相同的怪兽不能攻击，那个效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c41578483.distg)
	c:RegisterEffect(e4)
	-- ③：原本卡名和这张卡的效果装备的怪兽相同的怪兽不能攻击，那个效果无效化。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c41578483.discon)
	e6:SetOperation(c41578483.disop)
	c:RegisterEffect(e6)
	-- ③：原本卡名和这张卡的效果装备的怪兽相同的怪兽不能攻击，那个效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c41578483.atktg)
	c:RegisterEffect(e5)
end
-- 判断是否可以装备怪兽的辅助函数，始终返回true
function c41578483.can_equip_monster(c)
	return true
end
-- 效果发动时的条件判断，确保是对方怪兽的效果发动
function c41578483.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER)
end
-- 筛选可装备的对方怪兽的过滤条件，必须是场上或墓地的表侧表示效果怪兽
function c41578483.eqfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 选择装备目标的处理函数，用于选择对方场上或墓地的效果怪兽
function c41578483.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c41578483.eqfilter(chkc) end
	-- 判断是否满足装备条件，检查场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备条件，检查是否存在符合条件的对方怪兽
		and Duel.IsExistingTarget(c41578483.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标，从对方场上或墓地选择一只满足条件的怪兽
	local g=Duel.SelectTarget(tp,c41578483.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，记录装备怪兽将离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 装备限制条件函数，确保装备卡只能装备给该卡
function c41578483.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备操作的函数，将目标怪兽装备给自身
function c41578483.equip_monster(c,tp,tc)
	-- 尝试将目标怪兽装备给自身，若失败则返回
	if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(41578483,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 设置装备限制效果，确保装备卡只能装备给该卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c41578483.eqlimit)
	tc:RegisterEffect(e1)
end
-- 装备效果的执行函数，当满足条件时将目标怪兽装备给自身
function c41578483.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_EFFECT) and tc:IsControler(1-tp) then
		c41578483.equip_monster(c,tp,tc)
	end
end
-- 计算攻击力的函数，将装备怪兽的攻击力累加到自身
function c41578483.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(41578483)~=0 and tc:IsFaceup() and tc:GetAttack()>=0 then
			atk=atk+tc:GetAttack()
		end
		tc=g:GetNext()
	end
	return atk
end
-- 计算守备力的函数，将装备怪兽的守备力累加到自身
function c41578483.defval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(41578483)~=0 and tc:IsFaceup() and tc:GetDefense()>=0 then
			atk=atk+tc:GetDefense()
		end
		tc=g:GetNext()
	end
	return atk
end
-- 筛选已装备怪兽的过滤函数，必须是表侧表示且已装备的怪兽
function c41578483.disfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(41578483)~=0
end
-- 设置无效化效果的目标函数，判断是否为与装备怪兽同名的效果怪兽
function c41578483.distg(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(c41578483.disfilter,nil)
	return (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0) and g:IsExists(Card.IsOriginalCodeRule,1,nil,c:GetOriginalCodeRule())
end
-- 无效化效果的条件判断函数，判断对方发动的效果是否与装备怪兽同名
function c41578483.discon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(c41578483.disfilter,nil)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and g:IsExists(Card.IsOriginalCodeRule,1,nil,rc:GetOriginalCodeRule())
end
-- 无效化效果的执行函数，使对方发动的效果无效
function c41578483.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 设置不能攻击的目标函数，判断是否为与装备怪兽同名的怪兽
function c41578483.atktg(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(c41578483.disfilter,nil)
	return g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
