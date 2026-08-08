--巨骸竜フェルグラント
-- 效果：
-- 不死族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡已在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 定义卡片初始效果，包括同调召唤条件、复活限制以及两个主要效果。
function c65187687.initial_effect(c)
	-- 为当前卡添加同调召唤手续，要求调整怪兽作为素材，且必须包含不死族怪兽。
	aux.AddSynchroProcedure(c,c65187687.synfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 创建第一个效果：对方怪兽除外。设置效果描述、类别（移除）、类型（单次触发）、触发条件（特殊召唤成功）、属性（延迟、对象）和次数限制。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,65187687)
	e1:SetTarget(c65187687.rmtg)
	e1:SetOperation(c65187687.rmop)
	c:RegisterEffect(e1)
	-- 创建第二个效果：场上怪兽效果无效。设置效果描述、类别（无效化）、类型（场地型触发）、触发条件（特殊召唤成功）、作用范围（怪兽区域）、属性（延迟、对象）和次数限制。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上怪兽效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,65187687+o)
	e2:SetCondition(c65187687.discon)
	e2:SetTarget(c65187687.distg)
	e2:SetOperation(c65187687.disop)
	c:RegisterEffect(e2)
end
-- 定义同调召唤的过滤函数，用于筛选不死族怪兽作为调整素材。
function c65187687.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 定义移除目标的过滤函数，用于筛选可以被除外的怪兽（怪兽类型且可被移除）。
function c65187687.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 定义第一个效果的目标选择函数。优先从场上和墓地选择对方控制的、能够被移除的怪兽作为目标。
function c65187687.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c65187687.rmfilter(chkc) end
	-- 检查是否有满足条件的移除目标存在于场上或墓地。
	if chk==0 then return Duel.IsExistingTarget(c65187687.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 使用辅助函数从场上优先选择满足过滤条件的卡片作为目标。
	local g=aux.SelectTargetFromFieldFirst(tp,c65187687.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示当前连锁的操作是移除对方的怪兽。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 设置操作信息，表示当前连锁的操作是移除对方的墓地怪兽。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 定义第一个效果的操作函数。获取目标卡片，如果该卡片与效果相关，则将其从场上移除。
function c65187687.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以指定形式（正面表示）和理由（效果）将目标卡片从场上移除。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义特殊召唤过滤函数，用于筛选从墓地特殊召唤的怪兽。
function c65187687.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 定义第二个效果的条件判断函数。如果存在从墓地特殊召唤的怪兽，且当前卡片不是触发者，则返回 true。
function c65187687.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65187687.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 定义第二个效果的目标选择函数。选择场上表侧表示、可以被无效化的怪兽作为目标。
function c65187687.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查目标卡片是否在怪兽区域并且可以被无效化。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查是否有满足条件的无效化目标存在于怪兽区域。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 使用Duel.SelectTarget函数选择场上表侧表示、可以被无效化的怪兽作为目标。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义第二个效果的操作函数。获取当前卡片和目标卡片，如果目标卡片是表侧表示且与效果相关，则使其相关的连锁无效化，并赋予其不能攻击、不能成为效果的对象以及不能响应效果的持续无效化效果。
function c65187687.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前卡片的handler（即这张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁都无效化，并重置状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建单次效果，禁用目标怪兽的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建单次效果，禁用目标怪兽的触发式效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
