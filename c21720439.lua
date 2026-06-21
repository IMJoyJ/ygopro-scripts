--アルトメギア・ムーヴメント－血統－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。同名卡不在自己场上存在的1只「神艺」怪兽从卡组守备表示特殊召唤。
-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤和回收陷阱的效果并添加特殊召唤计数器
function s.initial_effect(c)
	-- 将「神艺学都 神艺学园」的卡片密码加入关联列表
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
	-- 注册用于检测从额外卡组特殊召唤非融合怪兽的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数：检测特殊召唤的怪兽是否不是从额外卡组特殊召唤，或者是否为融合怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 代价：检查本回合是否进行过非融合怪兽的额外特殊召唤，并施加本回合不能从额外卡组特殊召唤融合怪兽以外怪兽的限制
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测本回合是否没有从额外卡组特殊召唤过融合怪兽以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。同名卡不在自己场上存在的1只「神艺」怪兽从卡组守备表示特殊召唤。②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册本回合不能特殊召唤非融合怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能从额外卡组特殊召唤融合怪兽以外的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：对方场上的怪兽数量比自己场上的怪兽多
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上的怪兽数量是否比自己场上的怪兽多
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
end
-- 同名卡过滤函数：检查场上是否存在表侧表示的同名卡
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 特殊召唤的目标卡过滤：卡组中符合守备召唤条件的「神艺」怪兽，且自己场上没有同名卡
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 且自己场上不存在同名卡
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 效果①的发动准备（target）：判断自己场上是否有空位，且卡组中存在符合条件的特殊召唤目标怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果是在进行启动检测（chk==0），则判断自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中是否存在可以特殊召唤的符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的运行效果（activate）：若有空位，玩家从卡组选1只符合条件的怪兽以表侧守备表示特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上的怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择卡组中1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：此卡是作为「神艺学都 神艺学园」的效果发动的代价值（COST）而被送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:GetHandler():IsCode(74733322)
end
-- 检索卡片的过滤条件：自己墓地或除外状态的「神艺」陷阱卡且可以加入手牌
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1cd) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备（target）：判断墓地或除外区是否存在符合条件的卡，并设置加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果是在进行启动检测（chk==0），则判断墓地及除外区是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁处理操作信息：将墓地或除外区的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的运行效果（operation）：玩家选择墓地或除外区1张符合条件的卡加入手牌，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从墓地或除外状态的卡中选择1张符合条件且不受「王家长眠之谷」影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将被选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
