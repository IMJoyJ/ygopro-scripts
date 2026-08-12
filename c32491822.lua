--降雷皇ハモン
-- 效果：
-- 这张卡不能通常召唤。把自己场上3张表侧表示的永续魔法卡送去墓地的场合才能特殊召唤。
-- ①：只要这张卡在怪兽区域守备表示存在，对方怪兽不能选择这张卡以外的怪兽作为攻击对象。
-- ②：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方1000伤害。
function c32491822.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3张表侧表示的永续魔法卡送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c32491822.spcon)
	e2:SetTarget(c32491822.sptg)
	e2:SetOperation(c32491822.spop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32491822,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCondition(c32491822.damcon)
	e3:SetTarget(c32491822.damtg)
	e3:SetOperation(c32491822.damop)
	c:RegisterEffect(e3)
	-- 只要这张卡在怪兽区域守备表示存在，对方怪兽不能选择这张卡以外的怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetCondition(c32491822.atcon)
	e4:SetValue(c32491822.atlimit)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的永续魔法卡，包括表侧表示的和被影响状态下可以选为对象的里侧永续魔法卡。
function c32491822.spfilter(c,check)
	return c:IsAbleToGraveAsCost()
		and (c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS or check and c:IsFacedown() and c:IsType(TYPE_SPELL))
end
-- 检查玩家场上是否有3张满足条件的永续魔法卡，确保特殊召唤条件成立。
function c32491822.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家是否受到效果影响，影响永续魔法卡的选卡条件。
	local check=Duel.IsPlayerAffectedByEffect(tp,54828837)
	-- 获取满足特殊召唤条件的永续魔法卡组。
	local g=Duel.GetMatchingGroup(c32491822.spfilter,tp,LOCATION_ONFIELD,0,nil,check)
	-- 检查该卡组中是否存在3张满足条件的卡。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 选择满足条件的3张永续魔法卡并设置为特殊召唤的代价。
function c32491822.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检查玩家是否受到效果影响，影响永续魔法卡的选卡条件。
	local check=Duel.IsPlayerAffectedByEffect(tp,54828837)
	-- 获取满足特殊召唤条件的永续魔法卡组。
	local g=Duel.GetMatchingGroup(c32491822.spfilter,tp,LOCATION_ONFIELD,0,nil,check)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足条件的卡组中选择3张卡组成子集。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选中的卡组送去墓地，完成特殊召唤。
function c32491822.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡组以特殊召唤原因送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否满足发动伤害效果的条件，即该卡参与战斗且击败对方怪兽。
function c32491822.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 设置伤害效果的目标玩家和伤害值。
function c32491822.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为1000。
	Duel.SetTargetParam(1000)
	-- 设置伤害效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行伤害效果，对目标玩家造成1000点伤害。
function c32491822.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断该卡是否处于守备表示状态。
function c32491822.atcon(e)
	return e:GetHandler():IsDefensePos()
end
-- 限制对方不能选择该卡以外的怪兽作为攻击对象。
function c32491822.atlimit(e,c)
	return c~=e:GetHandler()
end
