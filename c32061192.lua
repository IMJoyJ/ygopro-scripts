--M∀LICE＜P＞Dormouse
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「码丽丝」怪兽除外。这个回合中自己场上的「码丽丝」怪兽的攻击力上升600。
-- ②：有这张卡位于所连接区的「码丽丝」连接怪兽不会被效果破坏。
-- ③：这张卡被除外的场合，支付300基本分才能发动。这张卡特殊召唤。这个回合，自己不是连接怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果的发动条件与处理
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。从卡组把1只「码丽丝」怪兽除外。这个回合中自己场上的「码丽丝」怪兽的攻击力上升600。
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
-- 过滤函数，用于筛选卡组中满足条件的「码丽丝」怪兽
function s.rmfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置①效果的发动条件，检查是否能从卡组除外1只「码丽丝」怪兽
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从卡组除外1只「码丽丝」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置①效果的发动信息，提示将要除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数，选择并除外1只「码丽丝」怪兽，并使自己场上的「码丽丝」怪兽攻击力上升600
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只「码丽丝」怪兽
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
	-- 创建一个使自己场上的「码丽丝」怪兽攻击力上升600的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(600)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力上升效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 设置攻击力上升效果的目标条件，使只有「码丽丝」怪兽生效
function s.atktg(e,c)
	return c:IsSetCard(0x1bf)
end
-- 设置②效果的目标条件，使只有位于连接区的「码丽丝」连接怪兽生效
function s.immtg(e,c)
	local lg=c:GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
		and lg and lg:IsContains(e:GetHandler()) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ③效果的费用支付函数，检查是否能支付300基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付300基本分
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 支付300基本分
	Duel.PayLPCost(tp,300)
end
-- ③效果的发动条件，检查是否能特殊召唤此卡并满足召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置③效果的发动信息，提示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理函数，将此卡特殊召唤，并设置本回合不能从额外卡组特殊召唤非连接怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建一个使本回合不能从额外卡组特殊召唤非连接怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤效果的目标条件，使非连接怪兽无法从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
