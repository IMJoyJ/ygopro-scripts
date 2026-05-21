--クシャトリラ・オーバーラップ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只怪兽为对象才能发动。从自己的手卡·墓地以及自己·对方场上的表侧表示怪兽之中选1只攻击力1500/守备力2100的怪兽除外，作为对象的怪兽的攻击力上升1500。
-- ②：这张卡被除外的场合，若自己场上有「俱舍怒威族」怪兽存在，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- ①：以场上1只怪兽为对象才能发动。从自己的手卡·墓地以及自己·对方场上的表侧表示怪兽之中选1只攻击力1500/守备力2100的怪兽除外，作为对象的怪兽的攻击力上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，若自己场上有「俱舍怒威族」怪兽存在，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤作为①效果对象的场上怪兽
function s.filter(c,tp)
	-- 检查怪兽是否表侧表示，且在手卡、墓地、双方场上（排除自身）存在至少1只满足除外条件的攻击力1500/守备力2100的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,1,c)
end
-- 过滤用于除外的怪兽：攻击力为1500、守备力为2100，且可以被除外
function s.rmfilter(c)
	return c:IsAttack(1500) and c:IsDefense(2100)
		and c:IsAbleToRemove() and c:IsFaceupEx()
end
-- ①效果的发动准备：进行对象选择的合法性检测，并设置除外操作的信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	-- 检查场上是否存在可以作为①效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：从双方的手卡、场上或墓地除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- ①效果的处理：除外1只攻击力1500/守备力2100的怪兽，并使对象怪兽的攻击力上升1500
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为①效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local exc
	if tc:IsRelateToEffect(e) then exc=tc end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从手卡、墓地或双方场上（排除对象怪兽）选择1只满足条件的攻击力1500/守备力2100的怪兽
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,1,1,exc)
	-- 如果成功除外了选中的怪兽
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 作为对象的怪兽的攻击力上升1500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	elseif #sg==0 and tc:IsRelateToEffect(e) and s.rmfilter(tc) then
		-- 将作为对象的怪兽除外（当没有其他可除外怪兽，且对象怪兽自身满足除外条件时的备用处理）
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤自己场上的「俱舍怒威族」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- ②效果的发动准备：检查自己场上是否有「俱舍怒威族」怪兽，并选择对方场上1只效果怪兽作为对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查当前指向的对象是否是对方场上的表侧表示效果怪兽
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在可以被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 且自己场上存在「俱舍怒威族」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只表侧表示效果怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：使选中的怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果的处理：使作为对象的对方怪兽的效果直到回合结束时无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为②效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 无效与该怪兽相关的连锁
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
