--ウィッチクラフトマスター・ヴェール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的魔法师族怪兽和对方怪兽进行战斗的伤害计算时才能发动。卡名不同的手卡的魔法卡任意数量给对方观看，那只自己怪兽的攻击力·守备力直到回合结束时上升给人观看的数量×1000。
-- ②：自己·对方回合，从手卡丢弃1张魔法卡才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
function c21522601.initial_effect(c)
	-- 创建效果，描述为“提升攻击”，类别为改变攻击力和防御力，类型为快速响应，触发条件为伤害计算时，生效范围为主怪兽区，限制每回合使用次数为1次（针对卡片ID 21522601），设置条件函数、目标选择函数和操作函数，并注册效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21522601,0))  --"提升攻击"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21522601)
	e1:SetCondition(c21522601.atkcon)
	e1:SetTarget(c21522601.atktg)
	e1:SetOperation(c21522601.atkop)
	c:RegisterEffect(e1)
	-- 创建效果，描述为“无效效果”，类别为无效化效果，类型为快速响应，提示时机为检查怪兽，触发条件为自由连锁，生效范围为主怪兽区，限制每回合使用次数为1次（针对卡片ID 21522602），设置消耗函数、目标选择函数和操作函数，并注册效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21522601,1))  --"无效效果"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21522602)
	e2:SetCost(c21522601.discost)
	e2:SetTarget(c21522601.distg)
	e2:SetOperation(c21522601.disop)
	c:RegisterEffect(e2)
end
-- 定义攻击条件函数：如果存在攻击目标，并且攻击方或被攻击方是魔法师族怪兽则返回真。
function c21522601.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象。
	return Duel.GetAttackTarget()
		-- 检查攻击者是否为当前回合玩家控制，且种族为魔法师族。
		and (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsRace(RACE_SPELLCASTER)
			-- 检查被攻击目标是否为当前回合玩家控制，且种族为魔法师族。
			or Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsRace(RACE_SPELLCASTER))
end
-- 定义卡片过滤函数：判断卡片是否为魔法卡并且未公开。
function c21522601.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 定义目标选择函数：如果存在满足过滤条件的在手牌位置的卡片则返回真。
function c21522601.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的手牌魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21522601.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 创建效果，描述为“提升攻击”，类别为改变攻击力和防御力，类型为快速响应，触发条件为伤害计算时，生效范围为主怪兽区，限制每回合使用次数为1次（针对卡片ID 21522601），设置条件函数、目标选择函数和操作函数，并注册效果。
function c21522601.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击者。
	local tc=Duel.GetAttacker()
	-- 如果攻击者是对方玩家控制的怪兽，则将攻击目标设置为当前回合玩家的怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	-- 从手牌中检索满足过滤条件的魔法卡组。
	local g=Duel.GetMatchingGroup(c21522601.cfilter,tp,LOCATION_HAND,0,nil)
	-- 向对方玩家发送提示信息，要求确认选择的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从检索到的魔法卡组中选择不重复的子集。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,#g)
	if not sg then return end
	-- 向对方玩家确认所选的卡片。
	Duel.ConfirmCards(1-tp,sg)
	-- 洗切当前回合玩家的手牌。
	Duel.ShuffleHand(tp)
	-- 创建单次效果，类型为单次持续，属性为不可无效化，代码为改变攻击力，数值为选择的魔法卡数量乘以1000，重置条件为事件、标准重置、阶段结束，并注册到目标怪兽上。这是提升攻击力的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(#sg*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end
-- 定义消耗过滤函数：如果卡片在手牌位置，则判断是否为魔法卡且可丢弃；否则，判断是否表侧表示、可以作为费用送去墓地并且具有特定效果（83289866），或者不属于特定卡码（32353566）且是指定卡组（0x128）的魔法/陷阱卡，且可丢弃。
function c21522601.costfilter(c,tp,res)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
		or not c:IsCode(32353566) and c:IsSetCard(0x128)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and c:IsLocation(LOCATION_DECK) and res
end
-- 定义消耗函数：如果当前回合玩家受到效果影响(32353566)并且这张卡属于卡组(0x128)，则判断是否存在满足过滤条件的卡片；否则，从手牌、场上或墓地检索满足过滤条件的卡片。提示选择要丢弃的手牌，如果所选卡片不在手牌位置，则使用效果计数限制并注册标识效果，然后将卡片送去墓地；否则，直接将卡片送去墓地。
function c21522601.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前回合玩家是否受到效果影响(32353566)并且这张卡属于卡组(0x128)。
	local res=Duel.IsPlayerAffectedByEffect(tp,32353566) and e:GetHandler():IsSetCard(0x128)
	-- 检查是否存在满足消耗过滤条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c21522601.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp,res) end
	-- 检索满足消耗过滤条件的手牌、场上或墓地卡片。
	local g=Duel.GetMatchingGroup(c21522601.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil,tp,res)
	-- 提示玩家选择要丢弃的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc:IsLocation(LOCATION_HAND) then
		local te=tc:IsHasEffect(83289866,tp)
		if te then
			te:UseCountLimit(tp)
			-- 使用效果计数限制，并注册标识效果。
			Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		end
		-- 将选定的卡片送去墓地作为费用。
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 将选定的手牌送去墓地作为费用和丢弃。
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 定义目标选择函数：如果存在满足辅助过滤器的表侧表示怪兽则返回真。
function c21522601.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足辅助过滤条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	-- 检索满足辅助过滤器的场上怪兽组。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,e:GetHandler())
	-- 设置当前处理的连锁的操作信息，类别为无效化效果，目标为检索到的怪兽组，数量为怪兽组的数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 定义操作函数：获取满足辅助过滤器的场上怪兽组，遍历每个怪兽，使其相关连锁无效化，并注册单次持续、禁用和禁用效果的效果。
function c21522601.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足辅助过滤器的场上怪兽组。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建单次效果，类型为单次持续，代码为禁用，重置条件为事件、标准重置、阶段结束，并注册到目标怪兽上。这是禁用怪兽的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建单次效果，类型为单次持续，代码为禁用效果，重置条件为事件、标准重置、阶段结束，数值为回合重置，并注册到目标怪兽上。这是禁用怪兽效果的效果。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
