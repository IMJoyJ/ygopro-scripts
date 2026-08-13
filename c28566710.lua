--ラストバトル！
-- 效果：
-- 自己的基本分1000分以下时，在对方的回合才能发动。选择自己的场上的1只怪兽，双方的其他的场上和手上的卡全部送去墓地。之后，对方从卡组选择1只怪兽攻击表示特殊召唤并进行战斗（玩家的战斗伤害为0）。回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局。
function c28566710.initial_effect(c)
	-- 自己的基本分1000分以下时，在对方的回合才能发动。选择自己的场上的1只怪兽，双方的其他的场上和手上的卡全部送去墓地。之后，对方从卡组选择1只怪兽攻击表示特殊召唤并进行战斗（玩家的战斗伤害为0）。回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCondition(c28566710.condition)
	e1:SetTarget(c28566710.target)
	e1:SetOperation(c28566710.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件的判断函数，用于检查当前是否满足卡片的发动限制。
function c28566710.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动者当前基本分是否在1000以下，并且当前回合是否为对方回合。
	return Duel.GetLP(tp)<=1000 and Duel.GetTurnPlayer()~=tp
end
-- 定义效果发动时的合法性检查与目标选择函数：确认己方场上有可选怪兽，且对方能够进行特殊召唤。
function c28566710.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）时，确认己方场上存在至少1只怪兽可以被选择。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认对方玩家具备特殊召唤怪兽的能力，否则不能发动。
		and Duel.IsPlayerCanSpecialSummon(1-tp) end
	-- 设置效果处理时向系统宣告：将从对方卡组特殊召唤1只怪兽，用于连锁响应和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
end
-- 定义卡组特殊召唤怪兽的筛选条件：要求该怪兽可被对方以表侧攻击表示特殊召唤，并满足召唤条件与苏生限制。
function c28566710.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 定义效果处理函数：先选择己方场上的1只怪兽，将双方场上和手卡的其他卡全部送入墓地；再由对方从卡组选择怪兽特殊召唤并进行战斗；最后注册回合结束时的胜负判定效果。
function c28566710.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家给出选择提示，提示内容为“请选择表侧表示的卡”，实际用于选择己方场上要保留的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果处理时，由当前玩家从自己场上选择1只怪兽（该怪兽会被保留，不送去墓地）。
	local tg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	-- 获取双方场上（怪兽区与魔法陷阱区）以及手卡的所有卡，作为之后要被送去墓地的对象集合。
	local hg=Duel.GetFieldGroup(tp,0xe,0xe)
	if tc then hg:RemoveCard(tc) end
	-- 将双方场上和手卡中除所选怪兽以外的所有卡全部送去墓地。
	Duel.SendtoGrave(hg,REASON_EFFECT)
	-- 向对方玩家给出选择提示，提示内容为“请选择要特殊召唤的卡”，用于从卡组选择怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由对方玩家从对方卡组选择1只满足条件的怪兽，作为要特殊召唤并进行战斗的怪兽。
	local g=Duel.SelectMatchingCard(1-tp,c28566710.spfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc then
		-- 中断当前效果处理，使之后的特殊召唤与伤害计算作为不同时处理，避免错过时点（如特殊召唤成功时的诱发效果）。
		Duel.BreakEffect()
		-- 将对方选择的怪兽以表侧攻击表示特殊召唤到对方场上。
		Duel.SpecialSummon(sc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		-- （玩家的战斗伤害为0）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_CHAIN)
		-- 将“双方玩家受到的战斗伤害为0”的永续效果注册到当前玩家，效果在本次连锁结束前有效。
		Duel.RegisterEffect(e1,tp)
		-- 如果己方选择保留的怪兽仍在场上，则用特殊召唤的怪兽与己方怪兽进行战斗伤害计算。
		if tc then Duel.CalculateDamage(sc,tc) end
	end
	-- 回合结束时场上还存在怪兽的玩家获得决斗的胜利。其他的情况算平局。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c28566710.checkop)
	-- 将“结束阶段进行胜负判定”的效果注册到当前玩家，使其在回合结束时触发。
	Duel.RegisterEffect(e1,tp)
end
-- 定义回合结束时的胜负判定函数：根据双方场上怪兽数量情况决定胜利者或平局。
function c28566710.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家0场上主要怪兽区的怪兽数量。
	local t1=Duel.GetFieldGroupCount(0,LOCATION_MZONE,0)
	-- 获取玩家1场上主要怪兽区的怪兽数量。
	local t2=Duel.GetFieldGroupCount(1,LOCATION_MZONE,0)
	if t1>0 and t2==0 then
		-- 若只有玩家0场上有怪兽，则宣告玩家0获得决斗胜利。
		Duel.Win(0,0x16)
	elseif t2>0 and t1==0 then
		-- 若只有玩家1场上有怪兽，则宣告玩家1获得决斗胜利。
		Duel.Win(1,0x16)
	else
		-- 若双方场上都有怪兽或都没有怪兽，则宣告平局（无玩家胜利）。
		Duel.Win(PLAYER_NONE,0x16)
	end
end
