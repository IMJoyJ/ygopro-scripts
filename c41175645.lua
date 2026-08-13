--沈黙の魔術師－サイレント・マジシャン
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只魔法师族怪兽解放的场合才能特殊召唤。
-- ①：这张卡的攻击力上升自己手卡数量×500。
-- ②：1回合1次，魔法卡发动时才能发动。那个发动无效。
-- ③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默魔术师」以外的1只「沉默魔术师」怪兽无视召唤条件特殊召唤。
function c41175645.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只魔法师族怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c41175645.spcon)
	e2:SetTarget(c41175645.sptg)
	e2:SetOperation(c41175645.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己手卡数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c41175645.value)
	c:RegisterEffect(e3)
	-- ②：1回合1次，魔法卡发动时才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41175645,0))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c41175645.condition)
	e4:SetTarget(c41175645.target)
	e4:SetOperation(c41175645.operation)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡被战斗或者对方的效果破坏的场合才能发动。从手卡·卡组把「沉默魔术师」以外的1只「沉默魔术师」怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(41175645,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c41175645.spcon2)
	e5:SetTarget(c41175645.sptg2)
	e5:SetOperation(c41175645.spop2)
	c:RegisterEffect(e5)
end
-- 定义“可解放的魔法师族怪兽”的筛选条件：目标需为魔法师族，解放后自己场上仍有可用怪兽区；若该怪兽不是自己控制的，则必须表侧表示。
function c41175645.spfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER)
		-- 额外要求该怪兽被解放后自己场上仍有空余怪兽区，且当对方控制该怪兽时必须为表侧表示，才能作为解放候选。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤手续的发动条件：检查自己能否解放1只满足条件的魔法师族怪兽来从手牌进行规则特殊召唤。
function c41175645.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家tp是否存在至少1只满足spfilter条件的可解放怪兽，以符合“解放1只魔法师族怪兽”这一特殊召唤手续。
	return Duel.CheckReleaseGroupEx(tp,c41175645.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择解放怪兽的阶段：从候选怪兽中选出1只要解放的魔法师族怪兽，将其保存到效果标签中，选择成功则手续可行。
function c41175645.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有可解放的怪兽组，并用spfilter筛选出可作为本次特殊召唤解放费用的魔法师族怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c41175645.spfilter,nil,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：取出之前选择保存的怪兽并解放。
function c41175645.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以“特殊召唤手续”为原因解放选中的怪兽。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 计算永续攻击力上升值：根据持有者手卡数量动态决定上升数值。
function c41175645.value(e,c)
	-- 返回自己手卡数量乘以500，作为这张卡的攻击力上升值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*500
end
-- ②效果的发动条件：在对方或自己发动魔法卡（含魔法卡的发动）且该发动可以无效时，且此卡没有被战斗破坏的状态下才能发动。
function c41175645.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 追加条件：该魔法卡的连锁可被无效，且此卡没有处于被战斗破坏的状态。
		and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果发动时无需选择对象，只要确认当前连锁中有可无效的魔法卡发动。
function c41175645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次效果将对当前连锁中的那张魔法卡（eg）进行发动无效处理。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果处理：直接无效那个魔法卡的发动。
function c41175645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁（ev）对应的魔法卡发动无效化。
	Duel.NegateActivation(ev)
end
-- ③效果的发动条件：这张卡被战斗破坏，或被对方的效果破坏（且破坏前由自己控制）时才能发动。
function c41175645.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选③效果要特殊召唤的怪兽：必须是「沉默魔术师」字段怪兽，卡名不是这张卡本身，且可以无视召唤条件进行特殊召唤。
function c41175645.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe8) and not c:IsCode(41175645)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③效果的发动目标检查：自己怪兽区有空位，并且手牌·卡组中存在满足过滤条件的可特殊召唤怪兽。
function c41175645.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时可处理性判定：要求自己场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时要求手牌·卡组中至少存在1张满足filter条件的「沉默魔术师」怪兽。
		and Duel.IsExistingMatchingCard(c41175645.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ③效果处理：从手卡·卡组选择1只符合条件的「沉默魔术师」怪兽，无视召唤条件特殊召唤到自己场上。
function c41175645.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己的怪兽区没有空位则直接终止，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选出满足filter条件的1只怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c41175645.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上，且不检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
