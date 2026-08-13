--アマゾネスの戦士長
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「亚马逊」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1张「亚马逊」魔法·陷阱卡或者「融合」在自己场上盖放。这个回合，自己不用「亚马逊」怪兽不能攻击。
local s,id,o=GetID()
-- 初始化效果函数：为这张卡注册①（手卡特殊召唤）和②（召唤·特殊召唤成功时盖放并附加攻击限制）三个效果对象。
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
-- 过滤条件：存在里侧表示怪兽或不是「亚马逊」怪兽时返回true，用于判断自己场上是否不是“没有怪兽或只有亚马逊怪兽”。
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x4)
end
-- ①的发动条件：自己场上不存在里侧表示或非亚马逊的怪兽，即没有怪兽或只有表侧「亚马逊」怪兽时满足。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在满足cfilter的怪兽（里侧或非亚马逊），不存在则条件成立。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①的发动目标检查：确认主怪兽区有空位且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否至少存在1个可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果处理为特殊召唤这张卡的操作信息，供后续连锁或效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡没有中途离场等失去联系的情况，则执行特殊召唤（表侧攻击表示，无苏生限制检查）。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②的检索过滤器：选择可盖放的卡，且是「亚马逊」魔法·陷阱卡或「融合」（24094653）。
function s.filter(c)
	return c:IsSSetable() and (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x4) or c:IsCode(24094653))
end
-- ②的发动目标检查：卡组中存在满足filter的卡才能发动。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「亚马逊」魔法·陷阱卡或「融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②的效果处理：先给自己场上的非亚马逊怪兽附加不能攻击的永续效果，然后从卡组选择1张符合条件的卡盖放到自己场上。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组选1张「亚马逊」魔法·陷阱卡或者「融合」在自己场上盖放。这个回合，自己不用「亚马逊」怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的永续效果注册到场上，持续影响tp方场上的非亚马逊怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 向玩家发送选择卡片的提示信息，提示内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从持有者tp的卡组中选择1张满足filter的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择到卡片，则将其盖放到tp的魔法·陷阱区。
	if #g>0 then Duel.SSet(tp,g) end
end
-- 不能攻击效果的过滤器：非「亚马逊」怪兽处于主要怪兽区时返回true，即不能攻击。
function s.atktg(e,c)
	return not c:IsSetCard(0x4)
end
