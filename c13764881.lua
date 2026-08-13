--チェーン・リゾネーター
-- 效果：
-- ①：场上有同调怪兽存在，这张卡召唤成功时才能发动。从卡组把「锁链共鸣者」以外的1只「共鸣者」怪兽特殊召唤。
function c13764881.initial_effect(c)
	-- ①：场上有同调怪兽存在，这张卡召唤成功时才能发动。从卡组把「锁链共鸣者」以外的1只「共鸣者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13764881,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c13764881.spcon)
	e1:SetTarget(c13764881.sptg)
	e1:SetOperation(c13764881.spop)
	c:RegisterEffect(e1)
end
-- 定义同调怪兽过滤条件：卡片为表侧表示且类型为同调怪兽（TYPE_SYNCHRO）。
function c13764881.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件判断：检查场上（双方主要怪兽区）是否存在至少1只表侧表示的同调怪兽。
function c13764881.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检索操作：在双方场上主要怪兽区中搜索至少1张满足cfilter条件的卡，若存在则发动条件成立。
	return Duel.IsExistingMatchingCard(c13764881.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 定义可特殊召唤的卡组怪兽条件：必须是「共鸣者」系列怪兽（SetCard 0x57）、不是「锁链共鸣者」本身、并且能够被特殊召唤（满足苏生限制和召唤条件）。
function c13764881.filter(c,e,tp)
	return c:IsSetCard(0x57) and not c:IsCode(13764881) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时检测（Target）：检查自己主要怪兽区是否有空位，同时卡组中是否存在符合条件的「共鸣者」怪兽，若满足则允许发动。
function c13764881.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件之一：自己主要怪兽区的可用空格数必须大于0，以保证特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 作为发动条件之二：卡组中存在至少1张满足filter条件的「共鸣者」怪兽（不是「锁链共鸣者」）可供特殊召唤。
		and Duel.IsExistingMatchingCard(c13764881.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：登记本次效果将进行特殊召唤，对象来自卡组，数目为1，持有者为己方，用于后续连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理操作：执行特殊召唤，先检查空位，再让玩家从卡组选择符合条件的「共鸣者」怪兽，以表侧表示特殊召唤到自己场上。
function c13764881.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若自己主要怪兽区没有空位，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡，显示“请选择要特殊召唤的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中筛选并选择1张满足filter条件的「共鸣者」怪兽（不能是「锁链共鸣者」）。
	local g=Duel.SelectMatchingCard(tp,c13764881.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择成功的怪兽以表侧表示特殊召唤到自己场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
