--リバース・ブレイカー
-- 效果：
-- 名字带有「希望皇 霍普」的怪兽才能装备。装备怪兽攻击宣言时，选择对方场上1张魔法·陷阱卡破坏。对方不能对应这个效果的发动把魔法·陷阱卡发动。
function c94950218.initial_effect(c)
	-- 名字带有「希望皇 霍普」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c94950218.target)
	e1:SetOperation(c94950218.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽攻击宣言时，选择对方场上1张魔法·陷阱卡破坏。对方不能对应这个效果的发动把魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94950218,0))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c94950218.descon)
	e2:SetTarget(c94950218.destg)
	e2:SetOperation(c94950218.desop)
	c:RegisterEffect(e2)
	-- 名字带有「希望皇 霍普」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c94950218.eqlimit)
	c:RegisterEffect(e3)
end
-- 装备限制：只能装备给名字带有「希望皇 霍普」的怪兽
function c94950218.eqlimit(e,c)
	return c:IsSetCard(0x107f)
end
-- 过滤条件：场上表侧表示的名字带有「希望皇 霍普」的怪兽
function c94950218.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备魔法卡发动时的效果处理（选择装备对象）
function c94950218.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c94950218.filter(chkc) end
	-- 检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c94950218.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c94950218.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理（执行装备）
function c94950218.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 破坏效果的发动条件：装备怪兽进行攻击宣言时
function c94950218.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击宣言的怪兽是否为装备怪兽
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 过滤条件：魔法或陷阱卡
function c94950218.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备（选择要破坏的卡并限制连锁）
function c94950218.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c94950218.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c94950218.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 限制连锁，使对方不能对应此效果发动魔法·陷阱卡
	Duel.SetChainLimit(c94950218.climit)
end
-- 破坏效果的处理（破坏目标卡片）
function c94950218.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 连锁限制函数：阻止对方发动魔法·陷阱卡
function c94950218.climit(e,lp,tp)
	return lp==tp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
