--ボスラッシュ
-- 效果：
-- 自己没有把怪兽通常召唤的回合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，自己不能把怪兽通常召唤。
-- ②：这张卡在魔法与陷阱区域存在的状态，自己场上的表侧表示的「巨大战舰」怪兽被破坏送去墓地的场合，那个回合的结束阶段才能发动。从卡组把1只「巨大战舰」怪兽特殊召唤。
function c66947414.initial_effect(c)
	-- 自己没有把怪兽通常召唤的回合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c66947414.condition)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不能把怪兽通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
	-- ②：这张卡在魔法与陷阱区域存在的状态，自己场上的表侧表示的「巨大战舰」怪兽被破坏送去墓地的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(c66947414.checkop)
	c:RegisterEffect(e4)
	-- 那个回合的结束阶段才能发动。从卡组把1只「巨大战舰」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66947414,0))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c66947414.spcon)
	e5:SetTarget(c66947414.sptg)
	e5:SetOperation(c66947414.spop)
	c:RegisterEffect(e5)
end
-- 定义发动条件函数，检查本回合是否进行过通常召唤
function c66947414.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家通常召唤（包括放置）的次数是否为0
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 定义过滤条件：自己场上因破坏送去墓地的「巨大战舰」怪兽
function c66947414.chkfilter(c,tp)
	return c:IsSetCard(0x15) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 定义事件处理函数，若有符合条件的「巨大战舰」怪兽被破坏送去墓地，则给这张卡注册一个在回合结束时重置的Flag
function c66947414.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c66947414.chkfilter,1,nil,tp) then
		e:GetHandler():RegisterFlagEffect(66947414,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 定义发动条件函数，检查自身是否注册了对应的Flag（即本回合是否有「巨大战舰」怪兽被破坏送去墓地）
function c66947414.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(66947414)~=0
end
-- 定义过滤条件：卡组中可以特殊召唤的「巨大战舰」怪兽
function c66947414.filter(c,e,tp)
	return c:IsSetCard(0x15) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果目标函数，检查怪兽区域空位数以及卡组中是否存在可特殊召唤的「巨大战舰」怪兽，并设置特殊召唤的操作信息
function c66947414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查卡组中是否存在至少1只满足特殊召唤条件的「巨大战舰」怪兽
		and Duel.IsExistingMatchingCard(c66947414.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数，从卡组选择1只「巨大战舰」怪兽特殊召唤到场上
function c66947414.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「巨大战舰」怪兽
	local g=Duel.SelectMatchingCard(tp,c66947414.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
