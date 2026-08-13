--ゴゴゴゴーレム－GF
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只名字带有「隆隆隆」的怪兽解放的场合才能特殊召唤。这张卡的攻击力变成解放的那只怪兽的原本攻击力2倍的数值。这张卡的战斗发生的对对方的战斗伤害变成一半。此外，1回合1次，对方场上有效果怪兽的效果发动时发动。这张卡的攻击力下降1500，那个效果无效。
function c2948263.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只名字带有「隆隆隆」的怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c2948263.spcon)
	e2:SetTarget(c2948263.sptg)
	e2:SetOperation(c2948263.spop)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	-- 设置这张卡战斗给予对方玩家的战斗伤害变为一半。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- 此外，1回合1次，对方场上有效果怪兽的效果发动时发动。这张卡的攻击力下降1500，那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2948263,0))  --"效果无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c2948263.discon)
	e4:SetTarget(c2948263.distg)
	e4:SetOperation(c2948263.disop)
	c:RegisterEffect(e4)
end
-- 特殊召唤解放素材的筛选函数：候选怪兽须为名字带有「隆隆隆」的怪兽，且该怪兽被解放后我方主要怪兽区仍有空位，同时该怪兽的控制者为我方或处于表侧表示。
function c2948263.spfilter(c,tp)
	return c:IsSetCard(0x59)
		-- 并且该怪兽被解放后我方场上仍有可用怪兽区；同时该怪兽的控制者为我方（无论表里）或为表侧表示。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则条件判定：若检查对象为空则直接允许（用于系统询问）；否则确认当前玩家场上是否存在至少1只满足spfilter条件的可解放「隆隆隆」怪兽作为素材。
function c2948263.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家tp是否存在至少1只可解放（非上级召唤用）且满足spfilter条件的「隆隆隆」怪兽，作为SPSUMMON_PROC的条件是否成立。
	return Duel.CheckReleaseGroupEx(tp,c2948263.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤手续的选材步骤：获取所有可解放的符合条件的「隆隆隆」怪兽，弹出选择提示，让玩家从中选择1只作为解放素材，并用e:SetLabelObject临时存储该怪兽，供后续处理使用。
function c2948263.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家tp场上可解放的怪兽组（不包括手卡），并过滤出名字带有「隆隆隆」且满足spfilter条件的候选怪兽组，供玩家选择解放素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c2948263.spfilter,nil,tp)
	-- 向玩家tp显示选择提示，提示内容为“请选择要解放的卡”（HINTMSG_RELEASE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前选定的解放素材并将其解放，然后根据该怪兽的原本攻击力为这张卡设置一个攻击力变为其2倍的效果。
function c2948263.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 解放选中的「隆隆隆」怪兽，解放原因指定为特殊召唤（REASON_SPSUMMON）。
	Duel.Release(tc,REASON_SPSUMMON)
	local atk=tc:GetBaseAttack()
	-- 这张卡的攻击力变成解放的那只怪兽的原本攻击力2倍的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk*2)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 无效效果的发动条件：此卡未处于被战斗破坏状态，触发连锁的效果可被无效，触发连锁的控制者为对方，效果类型为怪兽效果，且发动位置在怪兽区。
function c2948263.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的效果的控制者和发动位置，分别存入tgp与loc，用于判断是否为对方在怪兽区发动的怪兽效果。
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	-- 判定此卡未被战斗破坏，且当前连锁效果能够被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
		and tgp~=tp and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
end
-- 无效效果的目标选择阶段（不取对象）：直接允许发动，并设置操作信息，声明本效果将要无效的是触发连锁的效果（eg），数量为1。
function c2948263.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：效果分类为CATEGORY_DISABLE，目标为触发连锁的效果组eg，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果的处理：先进行最终条件判定，通过后无效对应连锁，并令这张卡的攻击力下降1500。
function c2948263.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 最终判定条件：本卡为里侧表示、或攻击力小于1500、或已与本效果失去关联、或当前处理的连锁序号不是目标连锁的下一连锁（ev+1）、或本卡已处于被战斗破坏状态时，直接终止处理。
	if c:IsFacedown() or c:GetAttack()<1500 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 使连锁ev的效果无效，这是该效果中“那个效果无效”的实际操作。
	Duel.NegateEffect(ev)
	-- 这张卡的攻击力下降1500，那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1500)
	c:RegisterEffect(e1)
end
