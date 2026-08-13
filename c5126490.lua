--ネオス・ワイズマン
-- 效果：
-- 这张卡不能通常召唤。把自己的怪兽区域的表侧表示的「元素英雄 新宇侠」和「于贝尔」各1只送去墓地的场合才能特殊召唤。
-- ①：场上的这张卡不会被效果破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害。自己基本分回复那只对方怪兽的守备力的数值。
function c5126490.initial_effect(c)
	-- 将效果原文中提到的「元素英雄 新宇侠」（89943723）和「于贝尔」（78371393）的卡号登记到这张卡上，表示这些卡名记载于本卡效果文本中。
	aux.AddCodeList(c,89943723,78371393)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己的怪兽区域的表侧表示的「元素英雄 新宇侠」和「于贝尔」各1只送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c5126490.spcon)
	e2:SetTarget(c5126490.sptg)
	e2:SetOperation(c5126490.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害。自己基本分回复那只对方怪兽的守备力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5126490,0))  --"回复&伤害"
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置②效果的发动条件：在伤害步骤结束时，且这张卡与战斗相关（未离场或处于战斗破坏状态）才满足条件。
	e3:SetCondition(aux.dsercon)
	e3:SetTarget(c5126490.damtg)
	e3:SetOperation(c5126490.damop)
	c:RegisterEffect(e3)
	-- ①：场上的这张卡不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 定义特殊召唤素材的筛选函数：怪兽必须是表侧表示，且可以作为代价送去墓地（不受“不能送墓”等限制）。
function c5126490.spfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 定义从候补组中选出两张素材的组合判定：送墓后自己场上仍有可用怪兽区（aux.mzctcheck），且两张卡分别是「元素英雄 新宇侠」和「于贝尔」（顺序不限）。
function c5126490.fselect(g,tp)
	-- 具体判断：选出的2张卡在作为素材送墓后自己仍有怪兽区空位，并且一张是「元素英雄 新宇侠」(89943723)、另一张是「于贝尔」(78371393)。
	return aux.mzctcheck(g,tp) and aux.gfcheck(g,Card.IsCode,89943723,78371393)
end
-- 特殊召唤手续的条件：当c为nil时询问条件直接视为满足；否则从自己主要怪兽区选择2张满足spfilter的素材，并检查是否满足fselect的组合要求，只有存在这样的素材才能进行对应的特殊召唤。
function c5126490.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己主要怪兽区域中所有满足spfilter（表侧表示且可送墓）的怪兽，作为可选素材的集合。
	local g=Duel.GetMatchingGroup(c5126490.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c5126490.fselect,2,2,tp)
end
-- 特殊召唤手续的选材处理：从候选组中选择恰好2张满足fselect的怪兽作为素材；选择成功后用KeepAlive保持组对象，并存入效果e的LabelObject，供实际处理时送去墓地；若无法选择则返回false使特殊召唤不进行。
function c5126490.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前可选的素材候补（表侧表示且可作送墓代价的怪兽），供玩家进行选择。
	local g=Duel.GetMatchingGroup(c5126490.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 显示选择提示，要求玩家选择要送去墓地的卡（提示文字为“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c5126490.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的实际执行：取出先前保存的素材组，将这2张怪兽以特殊召唤的理由送去墓地，然后清理临时组对象，完成召唤代价。
function c5126490.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的素材怪兽送去墓地（原因REASON_SPSUMMON），即把2只怪兽作为特殊召唤的代价送入墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ②效果的发动检查与操作信息登记：确认这张卡与对方怪兽进行过战斗且战斗对象存在；在效果发动时预先登记将造成伤害（对方怪兽攻击力）和回复（对方怪兽守备力）的信息。
function c5126490.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsStatus(STATUS_OPPO_BATTLE) and bc~=nil end
	-- 登记伤害操作信息：对手（1-tp）将受到数值等于战斗对象怪兽攻击力的效果伤害（用于连锁响应和时点判定）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
	-- 登记回复操作信息：自己（tp）将回复数值等于战斗对象怪兽守备力的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,bc:GetDefense())
end
-- ②效果处理：取得战斗对象怪兽当前的攻击力和守备力，负值按0处理；给与对方攻击力数值的伤害，让自己回复守备力数值的LP，最后完成伤害/回复的分解时点处理。
function c5126490.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local def=bc:GetDefense()
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	-- 给与对方玩家（1-tp）等于战斗对象怪兽攻击力数值的效果伤害（is_step=true表示作为伤害/回复流程中的一步，不立刻触发时点）。
	Duel.Damage(1-tp,atk,REASON_EFFECT,true)
	-- 让自己基本分回复等于战斗对象怪兽守备力数值的数值（同样以is_step=true分步处理）。
	Duel.Recover(tp,def,REASON_EFFECT,true)
	-- 完成本次伤害/回复的分解流程，触发相关变化时点（如伤害回复时点）。
	Duel.RDComplete()
end
