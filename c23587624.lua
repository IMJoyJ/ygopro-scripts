--青天の霹靂
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合才能发动。把1只原本等级是10星以下的不能通常召唤的怪兽无视召唤条件从手卡特殊召唤。这个效果特殊召唤的怪兽不受那只怪兽以外的自己的卡的效果影响，下次的对方结束阶段回到持有者卡组。这个回合，自己不能把怪兽通常召唤·特殊召唤，对方受到的全部伤害变成0。
function c23587624.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合才能发动。把1只原本等级是10星以下的不能通常召唤的怪兽无视召唤条件从手卡特殊召唤。这个效果特殊召唤的怪兽不受那只怪兽以外的自己的卡的效果影响，下次的对方结束阶段回到持有者卡组。这个回合，自己不能把怪兽通常召唤·特殊召唤，对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c23587624.condition)
	e1:SetTarget(c23587624.target)
	e1:SetOperation(c23587624.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件判定函数：用于检查是否符合“对方场上有怪兽存在，自己场上没有怪兽存在”的发动条件。
function c23587624.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方主要怪兽区存在怪兽且自己主要怪兽区不存在怪兽，即满足发动条件时返回真。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选从手卡特殊召唤的怪兽：原本等级为10星以下、是不能通常召唤的怪兽、属于怪兽卡，并且能被当前效果特殊召唤。
function c23587624.spfilter(c,e,tp)
	return c:GetOriginalLevel()<=10 and not c:IsSummonableCard() and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 定义效果发动时的目标检查函数：在发动阶段确认自己主要怪兽区有空位，并且手卡中存在符合特殊召唤条件的怪兽。
function c23587624.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在可发动性检查阶段（chk==0），确认自己主要怪兽区仍有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认手卡中存在至少1只满足spfilter筛选条件的怪兽，只有两者同时满足才能发动。
		and Duel.IsExistingMatchingCard(c23587624.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：声明本效果涉及从手卡进行1只怪兽的特殊召唤，供其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：若仍存在空格，则从手卡选择1只符合条件的怪兽表侧特殊召唤，并给它附加“不受那只怪兽以外的自己的卡的效果影响”和“下次对方结束阶段回持有者卡组”的效果；随后设置本回合自己不能通常召唤·特殊召唤、对方受到的全部伤害变成0的持续效果。
function c23587624.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认自己主要怪兽区有空位，避免因连锁导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽（提示信息为“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡中选出1只满足spfilter条件的怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,c23587624.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 若选择到了怪兽，则进行特殊召唤步骤：以表侧表示特殊召唤该怪兽（无视召唤条件，但仍检查苏生限制）。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽不受那只怪兽以外的自己的卡的效果影响
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c23587624.efilter)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1,true)
			-- 下次的对方结束阶段回到持有者卡组
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
		-- 完成特殊召唤处理（SpecialSummonStep的配套调用，将待特殊召唤的怪兽真正特殊召唤上场）。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不能把怪兽通常召唤·特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“不能通常召唤怪兽”的自肃效果注册给当前玩家，持续到这个回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 将“不能覆盖怪兽”的自肃效果注册给当前玩家，持续到这个回合结束。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将“不能特殊召唤怪兽”的自肃效果注册给当前玩家，持续到这个回合结束。
	Duel.RegisterEffect(e3,tp)
	-- 对方受到的全部伤害变成0
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(0)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方玩家受到的伤害数值变为0”的持续效果注册到场上，本回合有效。
	Duel.RegisterEffect(e4,tp)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e5:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方玩家受到的效果伤害变为0”的效果注册到场上，确保全部伤害都变为0。
	Duel.RegisterEffect(e5,tp)
end
-- 定义免疫过滤函数：只免疫来自同一位玩家（自己的卡）且不是免疫怪兽自身的效果。
function c23587624.efilter(e,re)
	return e:GetOwnerPlayer()==re:GetOwnerPlayer() and e:GetHandler()~=re:GetHandler()
end
-- 定义回卡组效果的触发条件：当前为对方回合（因此会在下次对方结束阶段触发）。
function c23587624.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是效果发动者，即当前是对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义回卡组效果的操作：将特殊召唤的怪兽送回持有者卡组并洗切。
function c23587624.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果持有者（那只特殊召唤的怪兽）送去持有者卡组并洗切，原因是效果处理。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
