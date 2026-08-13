--沈黙の剣士－サイレント・ソードマン
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只战士族怪兽解放的场合才能特殊召唤。
-- ①：自己·对方的准备阶段发动。这张卡的攻击力上升500。
-- ②：1回合1次，魔法卡发动时才能发动。那个发动无效。
-- ③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默剑士」以外的1只「沉默剑士」怪兽无视召唤条件特殊召唤。
function c15180041.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只战士族怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c15180041.spcon)
	e2:SetTarget(c15180041.sptg)
	e2:SetOperation(c15180041.spop)
	c:RegisterEffect(e2)
	-- ①：自己·对方的准备阶段发动。这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15180041,0))
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetOperation(c15180041.atkop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，魔法卡发动时才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15180041,1))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c15180041.condition)
	e4:SetTarget(c15180041.target)
	e4:SetOperation(c15180041.operation)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默剑士」以外的1只「沉默剑士」怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(15180041,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c15180041.spcon2)
	e5:SetTarget(c15180041.sptg2)
	e5:SetOperation(c15180041.spop2)
	c:RegisterEffect(e5)
end
-- 定义解放素材的筛选函数：要求对象是战士族，解放后我方场上仍有可用的怪兽区，且该怪兽为我方控制或表侧表示（用于特殊召唤的解放条件）。
function c15180041.spfilter(c,tp)
	return c:IsRace(RACE_WARRIOR)
		-- 追加判定：解放该怪兽后仍存在至少1个可用的怪兽区；且该怪兽要么由我控制，要么是表侧表示，可作为解放对象。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件函数：如果c为空则无条件通过；否则检查我方是否存在至少1张满足解放条件的战士族怪兽。
function c15180041.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方是否存在至少1张可解放且符合过滤条件的战士族怪兽，以此判断能否进行特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c15180041.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的选择阶段：从符合条件的战士族怪兽中选出1只作为解放素材；若选定则储存并返回true，否则返回false。
function c15180041.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取我方场上可解放的怪兽组，并用spfilter过滤出可作为特殊召唤解放素材的战士族怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c15180041.spfilter,nil,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理阶段：取出之前选择的解放素材，将其解放以完成特殊召唤手续。
function c15180041.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为理由将选择的素材怪兽解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 准备阶段效果处理：若此卡仍与效果关联且表侧表示，则给它附加攻击力上升500的效果（持续到离场或效果被无效）。
function c15180041.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：对方连锁为魔法卡的卡的发动，且该连锁可被无效化，同时此卡不处于战斗破坏状态。
function c15180041.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 追加判定：该连锁可以被无效化，且此卡未被战斗破坏（保证发动无效合理的状态）。
		and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的发动处理：不取对象；返回true并登记操作信息，表示要无效那次魔法卡的发动。
function c15180041.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次操作会使当前连锁中的魔法卡发动无效化，供时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的实际处理：使那次魔法卡的发动无效。
function c15180041.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前连锁中指定的那次发动无效化。
	Duel.NegateActivation(ev)
end
-- 效果③的发动条件：此卡被战斗破坏，或者被对方的效果破坏且破坏前由我方控制，并且破坏前在场上存在。
function c15180041.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤对象的过滤条件：是怪兽、属于「沉默剑士」字段、不是此卡自身，且能被无视召唤条件地特殊召唤。
function c15180041.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe7) and not c:IsCode(15180041)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果③的发动条件：我方怪兽区有空位，且手卡·卡组中存在至少1只满足filter条件的「沉默剑士」怪兽。
function c15180041.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果③发动时检查：我方怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡·卡组中是否存在至少1只符合条件的「沉默剑士」怪兽，作为效果③能否发动的依据。
		and Duel.IsExistingMatchingCard(c15180041.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：预计从手卡·卡组特殊召唤1只怪兽到场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果③处理：若怪兽区有空位，让玩家从手卡·卡组选择1只符合条件的「沉默剑士」怪兽，无视召唤条件表侧表示特殊召唤。
function c15180041.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认怪兽区有空位，若没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组选择1只符合filter条件的「沉默剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c15180041.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件、表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
