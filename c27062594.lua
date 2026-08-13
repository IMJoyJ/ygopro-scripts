--運命の扉
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能把这张卡发动。那次攻击无效。那之后，这张卡变成效果怪兽（恶魔族·光·1星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果让这张卡已特殊召唤的场合，自己准备阶段从自己墓地把「希望皇 霍普」怪兽任意数量除外才能发动（同名卡最多1张）。给与对方除外数量×500伤害，这张卡的攻击力上升那次伤害的数值。
function c27062594.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能把这张卡发动。那次攻击无效。那之后，这张卡变成效果怪兽（恶魔族·光·1星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c27062594.condition)
	e1:SetTarget(c27062594.target)
	e1:SetOperation(c27062594.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡已特殊召唤的场合，自己准备阶段从自己墓地把「希望皇 霍普」怪兽任意数量除外才能发动（同名卡最多1张）。给与对方除外数量×500伤害，这张卡的攻击力上升那次伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27062594,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c27062594.damcon)
	e2:SetCost(c27062594.damcost)
	e2:SetTarget(c27062594.damtg)
	e2:SetOperation(c27062594.damop)
	c:RegisterEffect(e2)
end
-- 发动条件判定函数：确认本次攻击是对方怪兽的直接攻击宣言（攻击怪兽为对方控制且攻击目标不存在）。
function c27062594.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击者是对方控制的怪兽、且当前没有攻击对象，即满足直接攻击宣言条件。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果发动目标检查：确认此卡发动合法，包括cost已检查、自己主怪兽区有空位、且自己能够将此卡特殊召唤为效果怪兽。
function c27062594.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 确认自己主要怪兽区域存在可用空格，用于之后特殊召唤此卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己当前能够把此卡作为恶魔族·光·1星·攻/守0的效果陷阱怪兽特殊召唤到怪兽区域。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27062594,0,TYPES_EFFECT_TRAP_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) end
	-- 设置操作信息，向系统声明本效果处理中涉及将此卡自身特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理函数：无效那次攻击，并在成功后把此卡特殊召唤为效果怪兽。若攻击无效失败或此卡已不满足特殊召唤条件则终止。
function c27062594.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效对方怪兽的攻击，如果攻击已经无法被无效（如已被其他效果无效）则处理失败并结束。
	if not Duel.NegateAttack() then return end
	-- 中断当前效果链，使之后的特殊召唤不与之前的攻击无效视为同一时点处理，避免错过时点。
	Duel.BreakEffect()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		-- 若此卡已不与发动效果关联，或当前玩家不能将其特殊召唤为效果怪兽，则不进行特殊召唤并结束处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,27062594,0,TYPES_EFFECT_TRAP_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以自身效果特殊召唤（SUMMON_VALUE_SELF）表侧表示特殊召唤到自己怪兽区域，使其变成效果怪兽继续存在。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- ②效果发动条件判定：确认此卡是由①效果以陷阱怪兽形式特殊召唤而来，并且现在是自己的准备阶段。
function c27062594.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡的召唤类型为自身效果的特殊召唤，且当前回合玩家是自己，即满足自己准备阶段时机。
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and Duel.GetTurnPlayer()==tp
end
-- 筛选函数：选择自己墓地中属于「希望皇 霍普」字段（0x107f）且可以作为代价除外的怪兽。
function c27062594.cfilter(c)
	return c:IsSetCard(0x107f) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动代价：从自己墓地选择任意数量（同名卡最多1张）的「希望皇 霍普」怪兽除外，并把除外数量记录在效果标签中用于后续伤害计算。
function c27062594.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少1张符合条件的「希望皇 霍普」怪兽可以除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c27062594.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 取得自己墓地中所有符合条件的「希望皇 霍普」怪兽作为可选项集合。
	local g=Duel.GetMatchingGroup(c27062594.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 显示选择提示，让发动玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从候选中选择1至全部数量的卡，且选择的卡卡名互不相同（同名卡最多1张），得到需要除外的卡组。
	local rg=g:SelectSubGroup(tp,aux.dncheck,false,1,g:GetCount())
	-- 把选择的卡以表侧表示除外作为代价，并记录实际除外的数量ct。
	local ct=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end
-- ②效果发动目标设定：指定对方玩家为伤害对象，伤害数值为除外数量×500，并写入操作信息。
function c27062594.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的伤害对象玩家设为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值参数设置为之前除外的卡数×500。
	Duel.SetTargetParam(e:GetLabel()*500)
	-- 设置操作信息：本效果将给对方造成（除外数量×500）的伤害，用于伤害相关连锁的检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*500)
end
-- ②效果处理：给对方造成记录数值的伤害，然后此卡的攻击力上升那次实际伤害的数值。
function c27062594.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前记录的伤害对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对对方造成d点伤害，实际伤害值存入val（可能因效果改变），作为攻击力上升的基准。
	local val=Duel.Damage(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那次伤害的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
