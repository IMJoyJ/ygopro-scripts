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
-- 定义破坏怪兽过滤函数，检查被破坏的卡片此前是否由自己控制、位于怪兽区、为超量怪兽，且破坏原因是战斗破坏或对方发动的效果破坏。
function c31712840.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 发动条件检查函数：确认被破坏的卡片组中存在至少1张除这张卡自身外符合己方超量怪兽被破坏条件的卡。
function c31712840.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31712840.cfilter,1,e:GetHandler(),tp)
end
-- 发动Cost函数：获取自己当前基本分，检查能否支付使基本分变为10的数值，并在发动时支付对应基本分。
function c31712840.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取发动玩家当前的基本分数值。
	local lp=Duel.GetLP(tp)
	-- 在检查能否发动时，确认玩家能够支付（当前基本分-10）点基本分（即当前基本分需大于10）。
	if chk==0 then return Duel.CheckLPCost(tp,lp-10) end
	-- 让发动玩家支付（当前基本分-10）点基本分，使其基本分变成10。
	Duel.PayLPCost(tp,lp-10)
end
-- 定义特殊召唤过滤函数，检查墓地中的卡片是否为「希望皇 霍普」(0x107f)怪兽且能以表侧表示正规特殊召唤。
function c31712840.spfilter(c,e,tp)
	return c:IsSetCard(0x107f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 发动目标检查函数：确认自己怪兽区有空位、墓地存在可特殊召唤的「希望皇 霍普」怪兽且卡组存在至少1张卡。
function c31712840.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检查能否发动时，确认自己主要怪兽区至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「希望皇 霍普」怪兽。
		and Duel.IsExistingMatchingCard(c31712840.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己卡组中是否至少还有1张卡。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_DECK,0,1,nil) end
	-- 向引擎登记本次连锁预计从自己墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：确认怪兽区有空位后，从墓地选1只「希望皇 霍普」怪兽特殊召唤并赋予攻击力翻倍、不被效果破坏及不被「No.」以外怪兽战破的效果；若特召成功，再从卡组选1张卡洗切卡组后放到最上面。
function c31712840.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己怪兽区可用空位是否小于等于0，若无空位则中止后续特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择要特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「希望皇 霍普」怪兽。
	local g=Duel.SelectMatchingCard(tp,c31712840.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local ss=false
	-- 若选中的怪兽存在，执行分解特殊召唤步骤以表侧表示将其特殊召唤到自己场上。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		ss=true
		-- 这个效果特殊召唤的怪兽攻击力变成2倍，
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
	-- 完成分解的特殊召唤流程，使所选的「希望皇 霍普」怪兽正式特殊召唤到场上。
	Duel.SpecialSummonComplete()
	if ss then
		-- 向玩家发送选择要放置在卡组最上面卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31712840,2))  --"请选择要放置在卡组最上面的卡"
		-- 让玩家从自己卡组中选择1张任意卡片。
		local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
		local tc2=g2:GetFirst()
		if tc2 then
			-- 手动洗切发动玩家的卡组。
			Duel.ShuffleDeck(tp)
			-- 将从卡组选中的那张卡移动到卡组最上面。
			Duel.MoveSequence(tc2,SEQ_DECKTOP)
		end
	end
end
-- 定义战斗破坏抗性过滤函数：当进行战斗的对方怪兽不属于「No.」(0x48)字段时返回true，表示不会被该怪兽战斗破坏。
function c31712840.indval(e,c)
	return not c:IsSetCard(0x48)
end
