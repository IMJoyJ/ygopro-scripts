--ゼアル・アライアンス
-- 效果：
-- ①：自己场上的表侧表示的超量怪兽被战斗或者对方的效果破坏的场合，把基本分支付到变成10基本分才能发动。从自己墓地选1只「希望皇 霍普」怪兽特殊召唤，从卡组选1张卡在卡组最上面放置。这个效果特殊召唤的怪兽攻击力变成2倍，不会被效果破坏，不会被和「No.」怪兽以外的怪兽的战斗破坏。
function c31712840.initial_effect(c)
	-- ①：自己场上的表侧表示的超量怪兽被战斗或者对方的效果破坏的场合，把基本分支付到变成10基本分才能发动。从自己墓地选1只「希望皇 霍普」怪兽特殊召唤，从卡组选1张卡在卡组最上面放置。这个效果特殊召唤的怪兽攻击力变成2倍，不会被效果破坏，不会被和「No.」怪兽以外的怪兽的战斗破坏。
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
-- 判断被破坏的怪兽是否为己方场上表侧表示的超量怪兽（原控制者是自己、原位置是主要怪兽区、类型为超量），且破坏原因是否为战斗破坏，或由对方玩家的效果破坏。
function c31712840.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果发动条件：被破坏的怪兽中存在至少1只满足上述条件的超量怪兽，即“自己场上的表侧表示的超量怪兽被战斗或对方的效果破坏”。
function c31712840.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31712840.cfilter,1,e:GetHandler(),tp)
end
-- 效果发动代价：把自己的基本分支付到变成10，即支付当前LP-10的LP作为代价。
function c31712840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己当前的LP数值。
	local lp=Duel.GetLP(tp)
	-- 在效果发动时（chk==0）检查自己能否支付当前LP-10的代价，也就是能否把LP支付到10。
	if chk==0 then return Duel.CheckLPCost(tp,lp-10) end
	-- 实际支付当前LP-10的LP，使自己的LP变为10。
	Duel.PayLPCost(tp,lp-10)
end
-- 筛选可特殊召唤的怪兽：持有「希望皇」字段（0x107f），且能够被自己以表侧表示特殊召唤。
function c31712840.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果发动前的合法性检查：自己怪兽区有空位、墓地有可特殊召唤的「希望皇 霍普」怪兽、卡组有卡可放到卡组顶，全部满足才能发动。
function c31712840.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的「希望皇」怪兽。
		and Duel.IsExistingMatchingCard(c31712840.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己卡组是否存在至少1张卡（用于选择放到卡组顶）。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_DECK,0,1,nil) end
	-- 向引擎登记本次效果处理包含“从墓地特殊召唤1只怪兽”的操作信息，供后续时点和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：确认怪兽区可用后，从墓地选1只「希望皇」怪兽特殊召唤，成功则给予攻击力2倍、效果破坏耐性和战斗破坏耐性；随后从卡组选1张卡放到卡组顶。
function c31712840.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己场上没有可用怪兽区，则无法进行特殊召唤，效果处理直接中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「希望皇」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c31712840.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local ss=false
	-- 若选中的怪兽存在且能够特殊召唤，则将其作为特殊召唤步骤进行特殊召唤（暂不完成，以便先附加后续效果）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		ss=true
		-- 这个效果特殊召唤的怪兽攻击力变成2倍。
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
	-- 结束特殊召唤步骤，使之前通过SpecialSummonStep处理的怪兽正式特殊召唤成功。
	Duel.SpecialSummonComplete()
	if ss then
		-- 显示“请选择要放置在卡组最上面的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31712840,2))  --"请选择要放置在卡组最上面的卡"
		-- 从自己卡组选择1张卡（无限制条件）作为要放到卡组顶的卡。
		local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
		local tc2=g2:GetFirst()
		if tc2 then
			-- 洗切卡组，确保后续将选中的卡移动到卡组顶时位置正确。
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最顶端。
			Duel.MoveSequence(tc2,SEQ_DECKTOP)
			-- 向双方玩家确认卡组最上方的1张卡（即刚放置的卡）。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 判定战斗破坏抗性：当对方怪兽不是「No.」怪兽时，这只特殊召唤的怪兽不会被那次战斗破坏。
function c31712840.indval(e,c)
	return not c:IsSetCard(0x48)
end
