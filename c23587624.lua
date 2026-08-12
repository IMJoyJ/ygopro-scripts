--青天の霹靂
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合才能发动。把1只原本等级是10星以下的不能通常召唤的怪兽无视召唤条件从手卡特殊召唤。这个效果特殊召唤的怪兽不受那只怪兽以外的自己的卡的效果影响，下次的对方结束阶段回到持有者卡组。这个回合，自己不能把怪兽通常召唤·特殊召唤，对方受到的全部伤害变成0。
function c23587624.initial_effect(c)
	-- 创建青天霹雳效果，设置为发动时点，条件为对方场上有怪兽且自己场上无怪兽，目标为特殊召唤，效果为发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c23587624.condition)
	e1:SetTarget(c23587624.target)
	e1:SetOperation(c23587624.activate)
	c:RegisterEffect(e1)
end
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合才能发动
function c23587624.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合才能发动
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选手卡中原本等级为10星以下、不能通常召唤、且可特殊召唤的怪兽
function c23587624.spfilter(c,e,tp)
	return c:GetOriginalLevel()<=10 and not c:IsSummonableCard() and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断是否满足发动条件，即自己场上存在空位且手卡有符合条件的怪兽
function c23587624.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c23587624.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 发动效果，选择并特殊召唤符合条件的怪兽，设置其免疫效果和返回卡组效果
function c23587624.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡中选择符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c23587624.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 特殊召唤选中的怪兽
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
			-- 设置特殊召唤的怪兽免疫自己场上的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c23587624.efilter)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1,true)
			-- 设置特殊召唤的怪兽在对方结束阶段回到卡组
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCountLimit(1)
			e2:SetCondition(c23587624.tdcon)
			e2:SetOperation(c23587624.tdop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	-- 设置自己本回合不能通常召唤、盖放、特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册自己不能通常召唤效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册自己不能盖放效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 注册自己不能特殊召唤效果
	Duel.RegisterEffect(e3,tp)
	-- 设置自己受到的伤害变为0，且对方受到的伤害也变为0
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(0)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册自己受到的伤害变为0效果
	Duel.RegisterEffect(e4,tp)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e5:SetReset(RESET_PHASE+PHASE_END)
	-- 注册对方受到的伤害也变为0效果
	Duel.RegisterEffect(e5,tp)
end
-- 效果免疫函数，免疫自己场上的效果
function c23587624.efilter(e,re)
	return e:GetOwnerPlayer()==re:GetOwnerPlayer() and e:GetHandler()~=re:GetHandler()
end
-- 返回对方结束阶段的条件函数
function c23587624.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合不是自己
	return Duel.GetTurnPlayer()~=tp
end
-- 返回对方结束阶段的处理函数
function c23587624.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽送回卡组
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
