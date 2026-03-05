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
	-- 效果作用
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
-- 判断目标怪兽是否为电子界族
function c14393464.atktg(e,c)
	return c:IsRace(RACE_CYBERSE)
end
-- 过滤函数，用于判断场上是否存在「斩机」怪兽
function c14393464.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x132) and c:IsType(TYPE_MONSTER)
end
-- 判断效果发动条件是否满足
function c14393464.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「斩机」怪兽且此卡处于表侧表示状态
	return Duel.IsExistingMatchingCard(c14393464.cfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 设置发动代价
function c14393464.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果对象选择
function c14393464.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查是否能选择对方场上的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定破坏效果的对象数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数
function c14393464.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
