--M∀LICE＜P＞Dormouse
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「码丽丝」怪兽除外。这个回合中自己场上的「码丽丝」怪兽的攻击力上升600。
-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽不会被效果破坏。
-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- initial_effect函数为这张卡注册三个效果：①起动除外卡组的「码丽丝」怪兽并提升攻击力，②给所连接区的「码丽丝」连接怪兽附加效果破坏抗性，③自身被除外的场合支付LP特召并附加额外卡组特召自肃。
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己主要阶段才能发动。从卡组把1只「码丽丝」怪兽除外。这个回合中自己场上的「码丽丝」怪兽的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.immtg)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选卡组中满足「码丽丝」怪兽、且当前可以被除外的卡，作为①除外的候选对象。
function s.rmfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 目标函数：发动时确认自己卡组存在符合条件的「码丽丝」怪兽，并设置本次连锁的除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中至少存在1张满足rmfilter的「码丽丝」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理时会从自己卡组除外1张卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 操作函数：从自己卡组选择1只「码丽丝」怪兽除外，并给自己场上的「码丽丝」怪兽附加600攻击力上升效果，持续到结束阶段。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示提示消息，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己卡组选择1张满足rmfilter的「码丽丝」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
	-- 这个回合中自己场上的「码丽丝」怪兽的攻击力上升600。②：有这张卡位于所连接区的「码丽丝」连接怪兽不会被效果破坏。③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(600)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力提升的永续效果注册到场上，使其在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击力提升效果的适用对象：自己场上的「码丽丝」怪兽。
function s.atktg(e,c)
	return c:IsSetCard(0x1bf)
end
-- ②的适用条件：对象为表侧表示的「码丽丝」连接怪兽，且其连接区包含这张卡，同时这张卡未被战斗破坏。
function s.immtg(e,c)
	local lg=c:GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
		and lg and lg:IsContains(e:GetHandler()) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ③的cost函数：检查能否支付300基本分并实际支付，作为发动条件。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查时确认玩家tp能否支付300基本分。
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 实际支付300基本分作为发动代价。
	Duel.PayLPCost(tp,300)
end
-- ③的目标函数：确认自己场上有可用的主要怪兽区空格，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查时确认自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将特殊召唤这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 操作函数：若这张卡仍与效果关联则将其特殊召唤，然后给自己附加“不是连接怪兽不能从额外卡组特殊召唤”的自肃效果直到结束阶段。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外卡组特召自肃效果注册到场上，持续至结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤条件：从额外卡组特殊召唤的怪兽必须为连接怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
