--アルトメギア・ムーヴメント－血統－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。同名卡不在自己场上存在的1只「神艺」怪兽从卡组守备表示特殊召唤。
-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①特殊召唤效果和②回收陷阱效果，并添加自定义活动计数器
function s.initial_effect(c)
	-- 记录该卡与「神艺学都 神艺学园」（卡号74733322）的关联
	aux.AddCodeList(c,74733322)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。同名卡不在自己场上存在的1只「神艺」怪兽从卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收陷阱"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 设置一个用于限制特殊召唤次数的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：若怪兽不是从额外卡组召唤或为融合怪兽，则不计入限制
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 效果发动时的费用处理：检查是否已使用过该效果，若未使用则设置不能特殊召唤的限制效果
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过该效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册不能特殊召唤的限制效果，仅对非融合怪兽生效
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：禁止非融合怪兽从额外卡组特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- ①效果的发动条件：对方场上的怪兽数量比自己场上的怪兽多
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上的怪兽数量比自己场上的怪兽多
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
end
-- 用于检查场上是否存在同名卡的过滤函数
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 用于筛选可特殊召唤的「神艺」怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 确保所选怪兽在场上没有同名卡存在
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- ①效果的目标设定：检查是否有满足条件的怪兽可特殊召唤
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：选择并特殊召唤符合条件的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件：该卡因支付费用被送去墓地且是为「神艺学都 神艺学园」的效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:GetHandler():IsCode(74733322)
end
-- 用于筛选可加入手牌的「神艺」陷阱卡的过滤函数
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1cd) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标设定：检查是否有满足条件的陷阱卡可加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地或除外状态是否存在满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁操作信息，表示将要将陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
