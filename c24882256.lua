--ファイアフェニックス＠イグニスター
-- 效果：
-- 电子界族怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡攻击的伤害计算时才能发动。给与对方这张卡的攻击力数值的伤害，那次战斗发生的对对方的战斗伤害变成0。
-- ②：这张卡被效果破坏的场合才能发动。选对方场上1只怪兽破坏。
-- ③：连接召唤的这张卡被破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
function c24882256.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只以上电子界族连接怪兽（通过Card.IsLinkRace过滤）作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡攻击的伤害计算时才能发动。给与对方这张卡的攻击力数值的伤害，那次战斗发生的对对方的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24882256,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,24882256)
	e1:SetCondition(c24882256.damcon)
	e1:SetTarget(c24882256.damtg)
	e1:SetOperation(c24882256.damop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②③的效果1回合各能使用1次。②：这张卡被效果破坏的场合才能发动。选对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24882256,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,24882257)
	e2:SetCondition(c24882256.descon)
	e2:SetTarget(c24882256.destg)
	e2:SetOperation(c24882256.desop)
	c:RegisterEffect(e2)
	-- ③：连接召唤的这张卡被破坏送去墓地的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c24882256.regop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②③的效果1回合各能使用1次。下次的准备阶段才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24882256,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,24882258)
	e4:SetCondition(c24882256.spcon)
	e4:SetTarget(c24882256.sptg)
	e4:SetOperation(c24882256.spop)
	c:RegisterEffect(e4)
end
-- 定义①效果的发动条件函数：仅当此卡是进行伤害计算的攻击怪兽时，①效果才满足发动条件。
function c24882256.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前战斗的攻击怪兽是否就是这张卡，作为①效果的发动条件。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 定义①效果的Target函数：发动时检查合法性（chk==0直接允许），并设置将给对方造成此卡攻击力数值伤害的操作信息。
function c24882256.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果属于伤害效果，目标为对方玩家，伤害数值为此卡当前攻击力（具体数值在效果处理时计算）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetAttack())
end
-- 定义①效果处理函数：若此卡仍在场上且表侧表示，则给对方造成此卡攻击力数值的效果伤害，并生成一个‘对方玩家本次伤害步骤不受到战斗伤害’的持续效果，使那次战斗对对方的战斗伤害变成0。
function c24882256.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 给对方造成等同于此卡当前攻击力的效果伤害。
	Duel.Damage(1-tp,c:GetAttack(),REASON_EFFECT)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡攻击的伤害计算时才能发动。给与对方这张卡的攻击力数值的伤害，那次战斗发生的对对方的战斗伤害变成0。②：这张卡被效果破坏的场合才能发动。选对方场上1只怪兽破坏。③：连接召唤的这张卡被破坏送去墓地的场合，下次的准备阶段才能发动。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将新创建的战斗伤害规避效果注册到tp方的效果场上，使该效果在本次伤害步骤内生效，用于影响对方玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 定义②效果的发动条件：这张卡是被效果破坏的场合才满足发动条件。
function c24882256.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义②效果的Target函数：发动时检查对方场上是否存在可破坏的怪兽；若存在，则将对方场上全部怪兽作为候选破坏对象，并设置破坏数量为1的操作信息。
function c24882256.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认对方场上至少存在1只怪兽，否则②效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有怪兽（无过滤条件），作为②效果可能破坏的对象集合。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果会破坏对方场上1只怪兽，候选对象为对方场上全部怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果的处理函数：提示操作者选择对方场上1只怪兽，若选择成功则显示选中动画并将该怪兽破坏。
function c24882256.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择卡片提示，提示内容为‘选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作者从对方场上选择1只怪兽（无额外过滤条件）作为②效果的破坏对象。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的怪兽播放被选为对象的动画，并记录该卡与当前效果的联系。
		Duel.HintSelection(g)
		-- 将选中的怪兽以效果破坏（送入墓地）。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 定义辅助效果e3的操作：当此卡因破坏从场上送去墓地，且此卡是连接召唤出场时，给自己注册一个标记（flag），表示其满足③效果的特殊召唤前提。
function c24882256.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK) then
		c:RegisterFlagEffect(24882256,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 定义③效果的发动条件：此卡在墓地，且不是在当回合被送去墓地（即已到下次准备阶段），并且带有e3登记的标记。
function c24882256.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回条件：此卡被送去墓地的回合不是当前回合，且带有③效果所需的标记（flag），从而只能在下次准备阶段发动。
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(24882256)>0
end
-- 定义③效果的Target函数：在发动时检查己方主要怪兽区有空位，且此卡能够被特殊召唤；满足则设置特殊召唤操作信息。
function c24882256.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，要求己方主要怪兽区存在空闲区域，否则③效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理时将此卡自身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(24882256)
end
-- 定义③效果的处理函数：若此卡仍与效果相关，则将其从墓地以表侧表示特殊召唤到自己场上。
function c24882256.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧表示特殊召唤到tp的场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
