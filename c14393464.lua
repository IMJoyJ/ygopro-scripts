--斬機帰納法
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的电子界族怪兽的攻击力上升500。
-- ②：自己场上有「斩机」怪兽存在的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
function c14393464.initial_effect(c)
	-- ①：自己场上的电子界族怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ②：自己场上有「斩机」怪兽存在的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c14393464.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 破坏对方场上一张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,14393464)
	e3:SetCondition(c14393464.descon)
	e3:SetCost(c14393464.cost)
	e3:SetTarget(c14393464.destg)
	e3:SetOperation(c14393464.desop)
	c:RegisterEffect(e3)
end
-- 只对电子界族怪兽生效。
function c14393464.atktg(e,c)
	return c:IsRace(RACE_CYBERSE)
end
-- 筛选场上存在的「斩机」怪兽。
function c14393464.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x132) and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足发动条件。
function c14393464.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在「斩机」怪兽且此卡处于启用状态。
	return Duel.IsExistingMatchingCard(c14393464.cfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 支付将此卡送去墓地的代价。
function c14393464.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 选择对方场上一张卡作为破坏对象。
function c14393464.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查是否有符合条件的目标卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张卡作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定破坏效果的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作。
function c14393464.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
