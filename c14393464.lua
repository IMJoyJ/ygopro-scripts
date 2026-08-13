--斬機帰納法
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的电子界族怪兽的攻击力上升500。
-- ②：自己场上有「斩机」怪兽存在的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
function c14393464.initial_effect(c)
	-- （魔法卡发动本身，无对应效果原文）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置该魔法卡可在伤害步骤且伤害计算前发动（伤害计算时点不能发动）。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：自己场上的电子界族怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c14393464.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「斩机」怪兽存在的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
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
-- 定义攻击力上升效果的适用对象筛选：只对自己场上的电子界族怪兽生效。
function c14393464.atktg(e,c)
	return c:IsRace(RACE_CYBERSE)
end
-- 定义②发动条件用筛选器：检查怪兽是否为表侧表示、属于「斩机」字段的怪兽。
function c14393464.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x132) and c:IsType(TYPE_MONSTER)
end
-- 定义②效果的发动条件：己方场上有表侧表示的「斩机」怪兽，且这张卡的魔法效果处于有效状态。
function c14393464.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否存在至少1只表侧表示的「斩机」怪兽，并且此卡自身效果有效。
	return Duel.IsExistingMatchingCard(c14393464.cfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 定义②的发动代价：将魔法与陷阱区域表侧表示的这张卡送去墓地才能发动；检查阶段确认此卡可作为代价送墓。
function c14393464.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送入墓地，作为发动代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义②的发动目标处理：选择对方场上1张卡作为对象，并设置对应的破坏操作信息。
function c14393464.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 效果发动合法性检查：对方场上是否存在至少1张可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为本连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本连锁的操作信息为“破坏”效果，对象为刚选择的1张卡，用于后续效果处理和相关判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②的效果处理：取得对象卡，若其仍与该效果有关联则将其破坏。
function c14393464.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对方场上的1张卡作为对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以“效果”为原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
