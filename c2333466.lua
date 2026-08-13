--破壊竜ガンドラＧ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升除外状态的卡数量×300。
-- ③：把基本分支付一半才能发动。场上的其他卡全部破坏并除外。那之后，从卡组把有「光之黄金柜」的卡名记述的1只7星以下的怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升这个效果破坏的卡数量的数值。
local s,id,o=GetID()
-- 注册此卡的全部效果：②为攻击力上升永续效果，①为手卡特召起动效果，③为破坏除外并特召的起动效果。
function s.initial_effect(c)
	-- 将「光之黄金柜」(79791878)登记为这张卡效果文本中记载的卡名，便于后续用aux.IsCodeListed判断“有「光之黄金柜」的卡名记述”。
	aux.AddCodeList(c,79791878)
	-- ②：这张卡的攻击力上升除外状态的卡数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	-- ①：自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把基本分支付一半才能发动。场上的其他卡全部破坏并除外。那之后，从卡组把有「光之黄金柜」的卡名记述的1只7星以下的怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升这个效果破坏的卡数量的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 定义②效果攻击力上升值的计算函数，返回除外状态卡数×300。
function s.value(e,c)
	-- 获取这张卡控制者除外区的卡数量并乘以300，作为攻击力上升数值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*300
end
-- 定义判定卡是否为表侧表示的「光之黄金柜」的过滤函数。
function s.cfilter(c)
	return c:IsCode(79791878) and c:IsFaceup()
end
-- 定义①效果的发动条件：自己场上有表侧表示的「光之黄金柜」存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1张表侧表示的「光之黄金柜」(79791878)。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义①效果发动时的目标处理：确认可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区有空位，且这张卡本身能够被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果处理时的实际操作：将这张卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 把这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义用于选择③效果特殊召唤对象的过滤函数：卡名记述有「光之黄金柜」、7星以下且可以被特殊召唤。
function s.spfilter(c,e,tp)
	-- 检查候选怪兽是否具备「光之黄金柜」卡名记述、是否等级在7以下且能否被特殊召唤。
	return aux.IsCodeListed(c,79791878) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(7)
end
-- 定义③效果的发动条件：卡组中存在符合条件的1只怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在满足s.spfilter条件的怪兽。
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
end
-- 定义③效果的发动cost：支付基本分的一半。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP一半的数值，作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义③效果发动时的目标处理：收集场上的其他卡作为破坏并除外对象，同时设置破坏和特召的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时确认这张卡以外存在场上卡，且玩家当前可以除外卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) and Duel.IsPlayerCanRemove(tp) end
	-- 获取这张卡以外的双方场上所有卡，作为可能被破坏并除外的对象组。
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息：破坏对象为场上其他所有卡，数量为其总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：之后将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 定义③效果处理时的完整流程：破坏并除外其他卡，再选择卡组中的怪兽特殊召唤，并为其附加等级上升效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时重新获取这张卡以外的双方场上所有卡。
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 判断对象组中是否存在衍生物，且玩家可以将其除外，用来确认之后是否确实有卡被除外。
	local rtc=sg:IsExists(Card.IsType,1,nil,TYPE_TOKEN) and Duel.IsPlayerCanRemove(tp)
	-- 将场上其他卡全部破坏并送去除外区，返回实际破坏数量。
	local ct=Duel.Destroy(sg,REASON_EFFECT,LOCATION_REMOVED)
	if ct==0 then return end
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if not rtc and rg:GetCount()==0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示，用于卡组选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足s.spfilter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 中断当前效果处理，使后续特殊召唤与前段破坏处理分开，避免丢失时点。
		Duel.BreakEffect()
		-- 将选择的怪兽以表侧攻击表示特殊召唤，并判断是否特殊召唤成功。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==1 then
			-- 这个效果特殊召唤的怪兽的等级上升这个效果破坏的卡数量的数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(ct)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			tc:RegisterEffect(e1)
		end
	end
end
