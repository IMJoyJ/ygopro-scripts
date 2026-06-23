--死配の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把怪兽攻击表示特殊召唤时，持有比那只怪兽高的攻击力的「咒眼」怪兽在自己场上存在的场合以那1只对方怪兽为对象才能把这张卡发动。得到那只怪兽的控制权。那只怪兽只要自己的魔法与陷阱区域有「太阴之咒眼」存在，也当作「咒眼」怪兽使用。那只怪兽从场上离开时这张卡破坏。
function c42899204.initial_effect(c)
	-- ①：对方把怪兽攻击表示特殊召唤时，持有比那只怪兽高的攻击力的「咒眼」怪兽在自己场上存在的场合以那1只对方怪兽为对象才能把这张卡发动。得到那只怪兽的控制权。
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
-- 过滤函数，检查场上是否存在满足条件的「咒眼」怪兽（攻击力高于目标怪兽）
function c42899204.filter(c,atk)
	return c:IsSetCard(0x129) and c:IsFaceup() and c:GetAttack()>atk
end
-- 过滤函数，检查目标怪兽是否满足发动条件（攻击表示、对方控制、己方场上存在攻击力更高的咒眼怪兽）
function c42899204.filter1(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsAttackPos() and c:IsControler(1-tp)
		-- 检查己方场上是否存在攻击力高于目标怪兽的「咒眼」怪兽
		and Duel.IsExistingMatchingCard(c42899204.filter,tp,LOCATION_MZONE,0,1,nil,c:GetAttack())
end
-- 设置效果目标为符合条件的对方怪兽，并设置操作信息为改变控制权
function c42899204.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c42899204.filter1(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c42899204.filter1,1,nil,e,tp) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	local tc=eg:FilterSelect(tp,c42899204.filter1,1,1,nil,e,tp):GetFirst()
	-- 将目标怪兽设置为当前连锁处理的对象
	Duel.SetTargetCard(tc)
	-- 设置操作信息为改变控制权效果
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 激活效果，将目标怪兽与当前卡片绑定
function c42899204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 设置控制权效果的值为当前卡片的持有者
function c42899204.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 过滤函数，检查己方魔法与陷阱区域是否存在「太阴之咒眼」
function c42899204.filter2(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 判断是否满足「太阴之咒眼」存在条件
function c42899204.setcon(e)
	-- 检查己方魔法与陷阱区域是否存在「太阴之咒眼」
	return Duel.IsExistingMatchingCard(c42899204.filter2,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
-- 判断目标怪兽是否从场上离开且为当前效果的目标
function c42899204.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当目标怪兽离开场上时，破坏此卡
function c42899204.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏此卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
