--眠れる巨人ズシン
-- 效果：
-- 这张卡不能通常召唤。把有咕咚指示物10个放置的1只自己怪兽解放的场合才能特殊召唤。
-- ①：1回合1次，把手卡的这张卡直到回合结束时给对方观看，以自己场上1只1星通常怪兽为对象才能发动。给那只怪兽放置1个咕咚指示物。
-- ②：这张卡不受其他卡的效果影响。
-- ③：这张卡和怪兽进行战斗的伤害计算时发动。这张卡的攻击力·守备力只在伤害计算时变成那只怪兽的攻击力＋1000的数值。
function c67547370.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把有咕咚指示物10个放置的1只自己怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c67547370.spcon)
	e2:SetTarget(c67547370.sptg)
	e2:SetOperation(c67547370.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，把手卡的这张卡直到回合结束时给对方观看，以自己场上1只1星通常怪兽为对象才能发动。给那只怪兽放置1个咕咚指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67547370,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1)
	e3:SetCost(c67547370.countcost)
	e3:SetTarget(c67547370.counttg)
	e3:SetOperation(c67547370.countop)
	c:RegisterEffect(e3)
	-- ②：这张卡不受其他卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c67547370.efilter)
	c:RegisterEffect(e4)
	-- ③：这张卡和怪兽进行战斗的伤害计算时发动。这张卡的攻击力·守备力只在伤害计算时变成那只怪兽的攻击力＋1000的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67547370,1))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(c67547370.atkcon)
	e5:SetOperation(c67547370.atkop)
	c:RegisterEffect(e5)
end
c67547370.mentioned_counter={
	[0x1039]=true,
}
-- 过滤条件：卡表侧表示、放置有10个咕咚指示物，且该卡离场后自己场上仍有可用的怪兽区域。
function c67547370.cfilter(c,tp)
	return c:IsFaceup() and c:GetCounter(0x1039)==10
		-- 并且该卡离场后自己场上还有空余的怪兽区域（用于特殊召唤这张卡）。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤条件：检查自己场上是否存在至少1只满足条件（放置10个咕咚指示物）的可解放怪兽。
function c67547370.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足cfilter条件的可解放的卡（作为特殊召唤的解放）。
	return Duel.CheckReleaseGroupEx(tp,c67547370.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤的对象选择处理：从可解放的卡中筛选满足条件的卡，让玩家选择1只要解放的怪兽并记录下来。
function c67547370.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己可解放的卡组，并过滤出表侧表示且放置有10个咕咚指示物、离场后仍有空怪兽区域的卡。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c67547370.cfilter,nil,tp)
	-- 向玩家发出「请选择要解放的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理：取出之前选择的怪兽并将其解放，以此特殊召唤这张卡。
function c67547370.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽以特殊召唤为目的解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 发动代价处理：确认这张卡尚未公开，然后给这张卡附加直到回合结束时公开手卡的效果（把手卡给对方观看）。
function c67547370.countcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	-- 把手卡的这张卡直到回合结束时给对方观看。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：卡为表侧表示的1星通常怪兽，且可以放置1个咕咚指示物。
function c67547370.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevel(1) and c:IsCanAddCounter(0x1039,1)
end
-- 取对象处理：以自己场上1只满足条件的1星通常怪兽为对象。
function c67547370.counttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67547370.filter(chkc) end
	-- 发动条件检查：自己场上存在至少1只可以作为对象的满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c67547370.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出「请选择表侧表示的卡」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的1星通常怪兽作为效果对象。
	Duel.SelectTarget(tp,c67547370.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其表侧表示且仍与效果关联，则给其放置1个咕咚指示物。
function c67547370.countop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1039,1)
	end
end
-- 免疫过滤：只对持有者不是这张卡本身的效果生效，即这张卡不受其他卡的效果影响。
function c67547370.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 发动条件：这张卡正在与怪兽进行战斗（存在战斗对象怪兽）。
function c67547370.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()
end
-- 伤害计算时的处理：计算对方战斗怪兽的攻击力＋1000的数值，若双方怪兽仍在战斗中且表侧表示，则让这张卡的攻击力·守备力只在伤害计算时变成该数值。
function c67547370.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local val=bc:GetAttack()+1000
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 这张卡的攻击力只在伤害计算时变成那只怪兽的攻击力＋1000的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(val)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
