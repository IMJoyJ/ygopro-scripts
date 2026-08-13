--絶望神アンチホープ
-- 效果：
-- 这张卡不能通常召唤。把自己场上4只表侧表示的1星怪兽送去墓地的场合才能从手卡·墓地特殊召唤。
-- ①：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击。
-- ②：这张卡进行战斗的战斗步骤中1次，把自己墓地1只1星怪兽除外才能发动。这张卡直到那次伤害步骤结束时不受其他卡的效果影响，不会被战斗破坏。
function c52085072.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上4只表侧表示的1星怪兽送去墓地的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c52085072.spcon)
	e2:SetTarget(c52085072.sptg)
	e2:SetOperation(c52085072.spop)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c52085072.antarget)
	c:RegisterEffect(e3)
	-- ②：这张卡进行战斗的战斗步骤中1次，把自己墓地1只1星怪兽除外才能发动。这张卡直到那次伤害步骤结束时不受其他卡的效果影响，不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52085072,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMING_BATTLE_PHASE)
	e4:SetCondition(c52085072.btcon)
	e4:SetCost(c52085072.btcost)
	e4:SetOperation(c52085072.btop)
	c:RegisterEffect(e4)
end
-- 判定满足特殊召唤素材条件的怪兽：表侧表示、等级为1、且可作为代价送去墓地。
function c52085072.spcfilter(c)
	return c:IsFaceup() and c:IsLevel(1) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的发动条件：若此卡在手牌或墓地，需存在4只符合条件的1星素材，且这些素材送去墓地后自己怪兽区仍有可用空格，才可进行特殊召唤。
function c52085072.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方场上所有满足“表侧表示·等级1·可作为代价送去墓地”条件的怪兽集合。
	local sg=Duel.GetMatchingGroup(c52085072.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查该集合中是否能选出4只作为素材，并保证这些素材被送墓后自己场上仍有足够的怪兽区域空位（处理格子限制）。
	return sg:CheckSubGroup(aux.mzctcheck,4,4,tp)
end
-- 选择特殊召唤素材的流程：让玩家从满足条件的怪兽中精确选择4只，选中后临时保存素材组，并在后续特召处理中将其送墓；若未选满则取消这次特殊召唤。
function c52085072.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家场上可作为特殊召唤素材的表侧1星怪兽集合。
	local sg=Duel.GetMatchingGroup(c52085072.spcfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从候选素材中选择4张卡（需满足送墓后仍有余裕），返回所选临时素材组。
	local g=sg:SelectSubGroup(tp,aux.mzctcheck,true,4,4,tp)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
-- 执行特殊召唤时的素材处理：从效果标签中取出之前保存的4只素材，将其送去墓地，然后清理临时组；特殊召唤本身由规则完成。
function c52085072.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的4只1星怪兽作为特殊召唤的素材从场上送入墓地，reason标记为REASON_SPSUMMON。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①的筛选：除持有者自身以外的己方怪兽都不能攻击（返回true表示不能攻击）。
function c52085072.antarget(e,c)
	return c~=e:GetHandler()
end
-- 效果②的发动条件：本卡在战斗阶段的战斗步骤中，且未处于连锁处理中、并作为攻击怪兽或攻击对象时才能发动。
function c52085072.btcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件前半段：现在处于战斗阶段（从开始到结束）且本卡未处于连锁处理状态。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 发动条件后半段：本卡正在进行战斗，即本卡是攻击者或攻击对象。
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 效果②代价的过滤：从自己墓地选择1只等级1的怪兽，且可作为代价除外。
function c52085072.btcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==1 and c:IsAbleToRemoveAsCost()
end
-- 代价合法性检查：墓地存在至少1只满足条件的1星怪兽，且本卡在本次伤害步骤结束前尚未使用过该效果（通过FlagEffect标记判断）。
function c52085072.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检查阶段确认：墓地存在可除外的1星素材且本卡没有发动过该效果的标记，满足则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52085072.btcfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():GetFlagEffect(52085072)==0 end
	-- 向玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只符合条件的1星怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c52085072.btcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将所选1星怪兽以表侧表示从墓地除外，作为发动效果的费用（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RegisterFlagEffect(52085072,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 处理②效果：若本卡仍与此效果关联且表侧表示，给本卡赋予“直到这次伤害步骤结束时免疫其他卡效果”和“不会被战斗破坏”两个效果。
function c52085072.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到那次伤害步骤结束时不受其他卡的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c52085072.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		c:RegisterEffect(e2)
	end
end
-- 免疫效果的判定：当某效果的持有者不是本卡自身时，返回true，即该效果对此卡无效化。
function c52085072.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
