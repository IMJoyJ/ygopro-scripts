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
	-- ②：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32491822,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCondition(c32491822.damcon)
	e3:SetTarget(c32491822.damtg)
	e3:SetOperation(c32491822.damop)
	c:RegisterEffect(e3)
	-- ①：只要这张卡在怪兽区域守备表示存在，对方怪兽不能选择其他怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetCondition(c32491822.atcon)
	e4:SetValue(c32491822.atlimit)
	c:RegisterEffect(e4)
end
-- 筛选可作为特殊召唤素材的魔法卡：能够作为cost送去墓地，且要么是表侧表示的永续魔法卡，要么在适用「失乐之霹雳」效果时是里侧表示的魔法卡。
function c32491822.spfilter(c,check)
	return c:IsAbleToGraveAsCost()
		and (c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS or check and c:IsFacedown() and c:IsType(TYPE_SPELL))
end
-- 特殊召唤条件的合法性检查：从自己场上筛选出可作为cost的魔法卡，并确认能选出3张且送去墓地后我方场上仍有可用怪兽区空格。
function c32491822.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方是否适用「失乐之霹雳」的效果，以决定素材选择是否包含里侧表示的魔法卡。
	local check=Duel.IsPlayerAffectedByEffect(tp,54828837)
	-- 获取自己场上可作为特殊召唤素材的魔法卡集合（filter中根据check决定是否包含里侧魔法卡）。
	local g=Duel.GetMatchingGroup(c32491822.spfilter,tp,LOCATION_ONFIELD,0,nil,check)
	-- 检查能否从候选集合中选出3张卡作为素材，且这些卡送去墓地后我方场上仍有空余的怪兽区域可用。
	return g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤的素材选择处理：选取3张满足条件的魔法卡作为送去墓地的cost，并保存选择结果供后续处理。
function c32491822.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检查我方是否适用「失乐之霹雳」的效果，以决定素材选择是否包含里侧表示的魔法卡。
	local check=Duel.IsPlayerAffectedByEffect(tp,54828837)
	-- 获取自己场上可作为特殊召唤素材的魔法卡集合（filter中根据check决定是否包含里侧魔法卡）。
	local g=Duel.GetMatchingGroup(c32491822.spfilter,tp,LOCATION_ONFIELD,0,nil,check)
	-- 给玩家显示选择提示，要求其选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从候选集合中选择3张卡作为素材；aux.mzctcheck确保送墓后我方可用的怪兽区域仍有空位。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：将之前选定的3张魔法卡送去墓地，完成特殊召唤的cost。
function c32491822.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选定的3张魔法卡送去墓地（作为特殊召唤的必要手续）。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果②的发动条件判定：本卡进行战斗并破坏了对方怪兽，且该怪兽被战斗送去墓地。
function c32491822.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 效果②的取对象/信息设置：将伤害对象设为对方玩家，伤害数值设为1000，并登记伤害效果信息。
function c32491822.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设为对方玩家（承受伤害者）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设为1000（即给予的伤害数值）。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：这是一个造成1000点伤害的效果，对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果②的实际处理：从连锁信息中读取对象玩家和伤害数值，给对方造成伤害。
function c32491822.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对对象玩家造成指定数值的伤害（原因记为效果伤害）。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果①的生效条件：这张卡在怪兽区域以守备表示存在。
function c32491822.atcon(e)
	return e:GetHandler():IsDefensePos()
end
-- 定义不能被选择为攻击对象的卡片：这张卡以外的怪兽不能被对方选择为攻击对象。
function c32491822.atlimit(e,c)
	return c~=e:GetHandler()
end
