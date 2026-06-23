--破壊竜ガンドラＧ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升除外状态的卡数量×300。
-- ③：把基本分支付一半才能发动。场上的其他卡全部破坏并除外。那之后，从卡组把有「光之黄金柜」的卡名记述的1只7星以下的怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升这个效果破坏的卡数量的数值。
local s,id,o=GetID()
-- 初始化效果，注册三个效果：攻击力提升、手卡特殊召唤、场上的其他卡破坏并特殊召唤。
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「光之黄金柜」的卡名。
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
-- 计算攻击力提升值，为除外卡数量乘以300。
function s.value(e,c)
	-- 返回除外卡数量乘以300作为攻击力提升值。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*300
end
-- 过滤函数，用于判断场上是否存在「光之黄金柜」的表侧表示怪兽。
function s.cfilter(c)
	return c:IsCode(79791878) and c:IsFaceup()
end
-- 判断条件函数，检查自己场上是否存在「光之黄金柜」的表侧表示怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「光之黄金柜」的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤目标函数，检查是否满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定特殊召唤的目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理函数，将自身从手卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将自身以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选卡组中符合条件的「光之黄金柜」怪兽。
function s.spfilter(c,e,tp)
	-- 筛选条件：该卡为「光之黄金柜」且等级不超过7，可以特殊召唤。
	return aux.IsCodeListed(c,79791878) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(7)
end
-- 破坏效果发动条件函数，检查卡组中是否存在符合条件的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在符合条件的「光之黄金柜」怪兽。
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
end
-- 破坏效果费用函数，支付一半基本分。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分作为费用。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 破坏效果目标函数，设置破坏和特殊召唤的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足破坏效果发动条件，即场上存在可破坏的卡且自己能除外卡。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) and Duel.IsPlayerCanRemove(tp) end
	-- 获取场上所有可除外的卡组成的组。
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息，确定破坏的目标为场上所有可破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息，确定特殊召唤的目标为卡组中符合条件的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 破坏效果处理函数，执行破坏并特殊召唤的操作。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有可破坏的卡组成的组，排除自身。
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 判断是否满足破坏后特殊召唤的条件。
	local rtc=sg:IsExists(Card.IsType,1,nil,TYPE_TOKEN) and Duel.IsPlayerCanRemove(tp)
	-- 执行破坏操作，将场上所有可破坏的卡破坏并除外。
	local ct=Duel.Destroy(sg,REASON_EFFECT,LOCATION_REMOVED)
	if ct==0 then return end
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if not rtc and rg:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 中断当前效果处理，使后续效果视为错时处理。
		Duel.BreakEffect()
		-- 执行特殊召唤操作，将选中的怪兽特殊召唤到场上。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==1 then
			-- 给特殊召唤的怪兽增加等级，等级增加量等于本次破坏的卡数量。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(ct)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			tc:RegisterEffect(e1)
		end
	end
end
