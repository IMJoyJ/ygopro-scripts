--強奪
-- 效果：
-- 可以给对方场上的怪兽装备。
-- ①：得到装备怪兽的控制权。
-- ②：对方准备阶段发动。对方回复1000基本分。
function c45986603.initial_effect(c)
	-- 可以给对方场上的怪兽装备。①：得到装备怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c45986603.target)
	e1:SetOperation(c45986603.operation)
	c:RegisterEffect(e1)
	-- ②：对方准备阶段发动。对方回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45986603,0))  --"对方回复1000基本分"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45986603.reccon)
	e2:SetTarget(c45986603.rectg)
	e2:SetOperation(c45986603.recop)
	c:RegisterEffect(e2)
	-- 可以给对方场上的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c45986603.eqlimit)
	c:RegisterEffect(e3)
	-- ①：得到装备怪兽的控制权。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_CONTROL)
	e4:SetValue(c45986603.ctval)
	c:RegisterEffect(e4)
end
-- 过滤函数：选择表侧表示且控制权可以被改变的怪兽，作为强夺的装备对象候选。
function c45986603.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 装备限制判定：允许装备给对方场上的怪兽（装备卡持有者不等于怪兽控制者），或保持已装备对象；禁止装备给我方怪兽。
function c45986603.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 发动时的目标选择处理：合法对象为对方场上的表侧表示且控制权可改变的怪兽；选择1只并设置控制权/装备的操作信息。
function c45986603.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45986603.filter(chkc) end
	-- 发动合法性检查：确认对方场上是否存在至少1只满足条件的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c45986603.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示，提示选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为效果对象，并登记为连锁目标。
	local g=Duel.SelectTarget(tp,c45986603.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将改变该怪兽的控制权，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：本连锁将把这张‘强夺’装备到对象怪兽上。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽均仍与效果关联且对象仍表侧表示，则将这张卡装备给对象怪兽。
function c45986603.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将强夺作为装备卡装备到目标怪兽上。
		Duel.Equip(tp,c,tc)
	end
end
-- ②效果发动条件：当前回合为对方回合（tp不等于当前回合玩家），即对方准备阶段时此效果才满足发动条件。
function c45986603.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：当前效果持有者不是回合玩家，确保只在对方准备阶段触发。
	return tp~=Duel.GetTurnPlayer()
end
-- ②效果的发动时处理：无需选择对象；指定对方玩家为回复对象，回复量为1000，并设置回复操作信息。
function c45986603.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁对象玩家设为对方玩家（1-tp），作为回复基本分的对象。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁参数为1000，即回复的基本分数量。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：该连锁为回复效果，目标玩家为对方，回复数值为1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- ②效果处理：从连锁信息取得对象玩家和回复数值，执行回复基本分。
function c45986603.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和参数（回复量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，原因为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 设置装备怪兽控制权归装备卡的持有者（我方），即获得该怪兽的控制权。
function c45986603.ctval(e,c)
	return e:GetHandlerPlayer()
end
