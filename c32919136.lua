--堕落
-- 效果：
-- 可以给对方场上的怪兽装备。
-- ①：得到装备怪兽的控制权。
-- ②：对方准备阶段发动。自己受到800伤害。
-- ③：自己场上没有「恶魔」卡存在的场合这张卡破坏。
function c32919136.initial_effect(c)
	-- ①：得到装备怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c32919136.target)
	e1:SetOperation(c32919136.operation)
	c:RegisterEffect(e1)
	-- ②：对方准备阶段发动。自己受到800伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32919136,0))  --"LP伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32919136.damcon)
	e2:SetTarget(c32919136.damtg)
	e2:SetOperation(c32919136.damop)
	c:RegisterEffect(e2)
	-- ③：自己场上没有「恶魔」卡存在的场合这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c32919136.descon)
	c:RegisterEffect(e3)
	-- 装备对象限制
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c32919136.eqlimit)
	c:RegisterEffect(e4)
	-- 装备怪兽的控制权变为自己
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_SET_CONTROL)
	e5:SetValue(c32919136.ctval)
	c:RegisterEffect(e5)
end
-- 筛选对方场上正面表示且控制权可改变的怪兽
function c32919136.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 装备对象限制判定函数
function c32919136.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 选择对方场上的怪兽作为装备对象
function c32919136.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32919136.filter(chkc) end
	-- 检查是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c32919136.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一个对方场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c32919136.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果处理函数
function c32919136.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 伤害发动条件判断
function c32919136.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保不是回合玩家触发
	return tp~=Duel.GetTurnPlayer()
end
-- 伤害效果处理准备
function c32919136.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害对象为自身
	Duel.SetTargetPlayer(tp)
	-- 设置伤害值为800
	Duel.SetTargetParam(800)
	-- 设置操作信息：造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,800)
end
-- 伤害效果处理函数
function c32919136.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的伤害对象和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 筛选自己场上的「恶魔」卡
function c32919136.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 破坏效果发动条件判断
function c32919136.descon(e)
	-- 若自己场上没有「恶魔」卡则破坏
	return not Duel.IsExistingMatchingCard(c32919136.desfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 控制权变更值设定为装备卡持有者
function c32919136.ctval(e,c)
	return e:GetHandlerPlayer()
end
