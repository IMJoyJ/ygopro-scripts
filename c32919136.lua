--堕落
-- 效果：
-- 可以给对方场上的怪兽装备。
-- ①：得到装备怪兽的控制权。
-- ②：对方准备阶段发动。自己受到800伤害。
-- ③：自己场上没有「恶魔」卡存在的场合这张卡破坏。
function c32919136.initial_effect(c)
	-- 可以给对方场上的怪兽装备。（发动时选择对象并装备）
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
	-- 可以给对方场上的怪兽装备。（限制装备对象为对方场上的怪兽）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c32919136.eqlimit)
	c:RegisterEffect(e4)
	-- ①：得到装备怪兽的控制权。（装备状态下将控制权转移给此卡控制者）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_SET_CONTROL)
	e5:SetValue(c32919136.ctval)
	c:RegisterEffect(e5)
end
-- 筛选对象：怪兽须表侧表示且控制权可以被改变。
function c32919136.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 装备限制条件：当此卡控制者与目标怪兽控制者不同（即对方怪兽），或目标怪兽已经是此卡的装备对象时允许装备。
function c32919136.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 发动时的目标处理：检查对方场上是否存在符合条件的怪兽，若存在则选择1张，并设置改变控制权和装备的操作信息。
function c32919136.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32919136.filter(chkc) end
	-- 发动合法性检查：对方场上是否存在至少1张表侧表示且可变更控制权的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c32919136.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上的符合条件的怪兽中选择1张作为效果对象并建立对象联系。
	local g=Duel.SelectTarget(tp,c32919136.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将改变1只怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置操作信息：本连锁将此卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡和对象怪兽仍与效果关联且对象怪兽仍表侧表示，则将此卡装备给对象怪兽。
function c32919136.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将此卡作为装备卡装备给对象怪兽，装备后适用装备效果。
		Duel.Equip(tp,c,tc)
	end
end
-- ②效果的发动条件：仅在对方回合的准备阶段满足。
function c32919136.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是此卡的控制者（即对方回合）。
	return tp~=Duel.GetTurnPlayer()
end
-- 伤害目标设定：发动时可用，将伤害对象设为此卡控制者，伤害值设为800，并写入操作信息。
function c32919136.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的伤害对象玩家设为此卡控制者（自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的伤害数值参数设为800。
	Duel.SetTargetParam(800)
	-- 设置操作信息：本连锁对此卡控制者造成800点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,800)
end
-- 伤害处理：从连锁信息中读取目标玩家和伤害数值，对目标玩家造成效果伤害。
function c32919136.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中保存的伤害对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成800点效果伤害，伤害原因为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ③的筛选函数：判定是否为表侧表示且字段为「恶魔」的卡。
function c32919136.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- ③自我破坏的发动条件：自己场上不存在表侧表示的「恶魔」卡。
function c32919136.descon(e)
	-- 检查自己场上是否没有符合条件的「恶魔」卡，没有则满足条件。
	return not Duel.IsExistingMatchingCard(c32919136.desfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 提供控制权转移的数值：将装备怪兽的控制权转移给此卡的控制者。
function c32919136.ctval(e,c)
	return e:GetHandlerPlayer()
end
