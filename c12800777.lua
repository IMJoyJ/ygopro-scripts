--風の精霊 ガルーダ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只风属性怪兽除外的场合可以特殊召唤。
-- ①：对方结束阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
function c12800777.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把1只风属性怪兽除外的场合可以特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c12800777.spcon)
	e1:SetTarget(c12800777.sptg)
	e1:SetOperation(c12800777.spop)
	c:RegisterEffect(e1)
	-- 对方结束阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12800777,0))  --"改变表示形式"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c12800777.poscon)
	e2:SetTarget(c12800777.postg)
	e2:SetOperation(c12800777.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地是否存在风属性且可除外的怪兽
function c12800777.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤的发动条件函数，判断是否满足特殊召唤条件
function c12800777.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的主怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家墓地是否存在至少1只风属性怪兽
		and Duel.IsExistingMatchingCard(c12800777.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤的目标选择函数，用于选择要除外的风属性怪兽
function c12800777.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家墓地中所有风属性怪兽的卡片组
	local g=Duel.GetMatchingGroup(c12800777.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理函数，执行将选定怪兽除外的操作
function c12800777.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以正面表示形式除外，作为特殊召唤的代价
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 表示形式变更效果的发动条件函数，判断是否为对方的结束阶段
function c12800777.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是效果持有者
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且可改变表示形式
function c12800777.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 表示形式变更效果的目标选择函数，用于选择要改变表示形式的对方怪兽
function c12800777.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c12800777.filter(chkc) end
	-- 检查是否存在至少1只符合条件的对方表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c12800777.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择符合条件的对方怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c12800777.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，标记本次效果将改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 表示形式变更效果的处理函数，执行改变目标怪兽表示形式的操作
function c12800777.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽改变为表侧攻击表示或表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
