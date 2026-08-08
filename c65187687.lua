--巨骸竜フェルグラント
-- 效果：
-- 不死族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡已在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤程序并注册两个触发效果
function c65187687.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（不死族）和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,c65187687.synfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：特殊召唤成功时发动，除外对方场上或墓地的1只怪兽
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
	-- 效果②：己方怪兽区域存在时，从墓地特殊召唤怪兽时发动，使对方场上1只表侧表示怪兽效果无效直到回合结束
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
-- 同调召唤所需调整的过滤条件，要求不死族
function c65187687.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 除外效果的过滤条件，要求是怪兽且能被除外
function c65187687.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果①的目标选择函数，从对方场上或墓地选择1只满足条件的怪兽作为目标
function c65187687.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c65187687.rmfilter(chkc) end
	-- 判断效果①是否可以发动，检查对方场上或墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c65187687.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择满足条件的卡作为目标，若无则从墓地选择
	local g=aux.SelectTargetFromFieldFirst(tp,c65187687.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示将从对方墓地除外卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 设置操作信息，表示将从对方场上除外卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 效果①的处理函数，执行除外操作
function c65187687.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否为从墓地特殊召唤的怪兽的过滤条件
function c65187687.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 效果②的发动条件，判断是否有从墓地特殊召唤的怪兽且不包含自身
function c65187687.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65187687.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 效果②的目标选择函数，选择对方场上1只可以被无效的效果怪兽作为目标
function c65187687.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断效果②是否可以发动，检查对方场上是否存在满足条件的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 判断效果②是否可以发动，检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只可以被无效的效果怪兽作为目标
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的处理函数，使目标怪兽效果无效
function c65187687.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效的永续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
