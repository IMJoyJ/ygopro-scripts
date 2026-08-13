--死配の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把怪兽攻击表示特殊召唤时，持有比那只怪兽高的攻击力的「咒眼」怪兽在自己场上存在的场合以那1只对方怪兽为对象才能把这张卡发动。得到那只怪兽的控制权。那只怪兽只要自己的魔法与陷阱区域有「太阴之咒眼」存在，也当作「咒眼」怪兽使用。那只怪兽从场上离开时这张卡破坏。
function c42899204.initial_effect(c)
	-- 对方把怪兽攻击表示特殊召唤时，持有比那只怪兽高的攻击力的「咒眼」怪兽在自己场上存在的场合以那1只对方怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTarget(c42899204.target)
	e1:SetOperation(c42899204.activate)
	c:RegisterEffect(e1)
	-- 得到那只怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c42899204.ctval)
	c:RegisterEffect(e2)
	-- 那只怪兽只要自己的魔法与陷阱区域有「太阴之咒眼」存在，也当作「咒眼」怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c42899204.setcon)
	e3:SetValue(0x129)
	c:RegisterEffect(e3)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c42899204.descon)
	e4:SetOperation(c42899204.desop)
	c:RegisterEffect(e4)
end
-- 筛选自己场上表侧表示、攻击力高于指定攻击力的「咒眼」怪兽，用于判断是否存在攻击力更高的「咒眼」怪兽。
function c42899204.filter(c,atk)
	return c:IsSetCard(0x129) and c:IsFaceup() and c:GetAttack()>atk
end
-- 判断对方怪兽能否成为此卡发动对象：必须是攻击表示、控制者为对方、能成为效果对象，且自己场上有攻击力更高的「咒眼」怪兽。
function c42899204.filter1(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsAttackPos() and c:IsControler(1-tp)
		-- 检查自己场上是否存在至少1张攻击力高于该对方怪兽攻击力的表侧表示「咒眼」怪兽，以满足发动条件。
		and Duel.IsExistingMatchingCard(c42899204.filter,tp,LOCATION_MZONE,0,1,nil,c:GetAttack())
end
-- 发动时从满足条件的对方怪兽中选择1只作为对象，并设置操作信息为获得控制权；同时检查发动时机是否合法。
function c42899204.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c42899204.filter1(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c42899204.filter1,1,nil,e,tp) end
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	local tc=eg:FilterSelect(tp,c42899204.filter1,1,1,nil,e,tp):GetFirst()
	-- 将选择的怪兽设置为当前连锁的对象，供后续效果处理时引用。
	Duel.SetTargetCard(tc)
	-- 设置本次效果的操作信息为改变控制权，目标为选择的怪兽，数量为1，供系统及关联卡判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽仍与效果关联，则将对象怪兽设为这张卡的永续对象，为后续控制权变更、字段附加、离场破坏提供依据。
function c42899204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 返回这张卡的控制者作为控制权变更的目标玩家，即将对象怪兽的控制权转移给这张卡的控制者。
function c42899204.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断卡是否为表侧表示的「太阴之咒眼」（卡号44133040）。
function c42899204.filter2(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 判断这张卡的控制者自己的魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」，作为对象怪兽获得「咒眼」字段的条件。
function c42899204.setcon(e)
	-- 检查控制者魔陷区是否存在至少1张表侧表示的「太阴之咒眼」。
	return Duel.IsExistingMatchingCard(c42899204.filter2,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
-- 作为离场触发条件：这张卡未被预定破坏、存在永续对象，且该对象怪兽在本次离场事件中离场，从而触发破坏。
function c42899204.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当对象怪兽从场上离开时，执行破坏这张卡的处理。
function c42899204.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
