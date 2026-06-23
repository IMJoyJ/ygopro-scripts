--ゼアル・アライアンス
-- 效果：
-- ①：自己场上的表侧表示的超量怪兽被战斗或者对方的效果破坏的场合，把基本分支付到变成10基本分才能发动。从自己墓地选1只「希望皇 霍普」怪兽特殊召唤，从卡组选1张卡在卡组最上面放置。这个效果特殊召唤的怪兽攻击力变成2倍，不会被效果破坏，不会被和「No.」怪兽以外的怪兽的战斗破坏。
function c31712840.initial_effect(c)
	-- 创建效果，设置为发动时触发，条件为己方场上的超量怪兽被战斗或对方效果破坏，支付LP至10分，特殊召唤墓地「希望皇 霍普」怪兽并从卡组选1张卡放至卡组最上方
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31712840,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c31712840.spcon)
	e1:SetCost(c31712840.spcost)
	e1:SetTarget(c31712840.sptg)
	e1:SetOperation(c31712840.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断被破坏的怪兽是否为己方场上的超量怪兽且由战斗或对方效果破坏
function c31712840.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 条件函数，检查是否有满足过滤条件的怪兽被破坏
function c31712840.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31712840.cfilter,1,e:GetHandler(),tp)
end
-- 支付LP至10分的费用处理
function c31712840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家LP
	local lp=Duel.GetLP(tp)
	-- 检查是否能支付LP至10分
	if chk==0 then return Duel.CheckLPCost(tp,lp-10) end
	-- 支付LP至10分
	Duel.PayLPCost(tp,lp-10)
end
-- 过滤函数，用于选择墓地中的「希望皇 霍普」怪兽
function c31712840.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 目标函数，检查是否满足特殊召唤条件和卡组有卡可放置
function c31712840.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在「希望皇 霍普」怪兽
		and Duel.IsExistingMatchingCard(c31712840.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查卡组是否存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，确定特殊召唤的怪兽来源为墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行特殊召唤和卡组放置操作
function c31712840.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有空位，无空位则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「希望皇 霍普」怪兽
	local g=Duel.SelectMatchingCard(tp,c31712840.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local ss=false
	-- 尝试特殊召唤选中的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		ss=true
		-- 将特殊召唤的怪兽攻击力变为2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetValue(c31712840.indval)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31712840,1))  --"「异热同心联盟」效果适用中"
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	if ss then
		-- 提示玩家选择要放置在卡组最上方的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31712840,2))  --"请选择要放置在卡组最上面的卡"
		-- 选择卡组中的任意一张卡
		local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
		local tc2=g2:GetFirst()
		if tc2 then
			-- 洗切玩家卡组
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最上方
			Duel.MoveSequence(tc2,SEQ_DECKTOP)
			-- 确认卡组最上方的卡
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 战斗破坏抗性判断函数，若怪兽不是「No.」怪兽则不会被战斗破坏
function c31712840.indval(e,c)
	return not c:IsSetCard(0x48)
end
