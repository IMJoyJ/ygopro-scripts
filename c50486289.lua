--アマゾネスの戦士長
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「亚马逊」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1张「亚马逊」魔法·陷阱卡或者「融合」在自己场上盖放。这个回合，自己不用「亚马逊」怪兽不能攻击。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果的发动条件和处理
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有「亚马逊」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1张「亚马逊」魔法·陷阱卡或者「融合」在自己场上盖放。这个回合，自己不用「亚马逊」怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在非「亚马逊」怪兽或里侧表示的怪兽
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x4)
end
-- 判断是否满足①效果的发动条件：自己场上的怪兽不存在或只有「亚马逊」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上的怪兽不存在或只有「亚马逊」怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置①效果的目标，检查是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数，执行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡存在于场上，则进行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤函数，用于选择可盖放的「亚马逊」魔法或陷阱卡或「融合」
function s.filter(c)
	return c:IsSSetable() and (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x4) or c:IsCode(24094653))
end
-- 设置②效果的目标，检查是否可以从卡组选择符合条件的卡
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理函数，设置不能攻击的效果并选择盖放卡
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置不能攻击的效果，使非「亚马逊」怪兽不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果选择了卡，则将其盖放到场上
	if #g>0 then Duel.SSet(tp,g) end
end
-- 用于判断是否为「亚马逊」怪兽，以决定是否可以攻击
function s.atktg(e,c)
	return not c:IsSetCard(0x4)
end
