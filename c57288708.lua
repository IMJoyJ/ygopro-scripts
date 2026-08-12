--星遺物－『星杯』
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：从额外卡组有怪兽特殊召唤的场合，把这张卡解放才能发动。那些怪兽送去墓地。
-- ②：通常召唤的表侧表示的这张卡从场上离开的场合才能发动。从卡组把「星遗物-『星杯』」以外的2只「星杯」怪兽特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从卡组把1张「星遗物」卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c57288708.initial_effect(c)
	-- 为单张卡片注册一个合并的延迟特殊召唤成功事件监听器，用于处理多只怪兽同时特殊召唤时的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,57288708,EVENT_SPSUMMON_SUCCESS)
	-- ①：从额外卡组有怪兽特殊召唤的场合，把这张卡解放才能发动。那些怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57288708,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c57288708.tgcon)
	e1:SetCost(c57288708.tgcost)
	e1:SetTarget(c57288708.tgtg)
	e1:SetOperation(c57288708.tgop)
	c:RegisterEffect(e1)
	-- ②：通常召唤的表侧表示的这张卡从场上离开的场合才能发动。从卡组把「星遗物-『星杯』」以外的2只「星杯」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57288708,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,57288708)
	e2:SetCondition(c57288708.spcon)
	e2:SetTarget(c57288708.sptg)
	e2:SetOperation(c57288708.spop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从卡组把1张「星遗物」卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57288708,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,57288709)
	-- 设置效果③的发动条件：这张卡送去墓地的回合不能发动
	e3:SetCondition(aux.exccon)
	-- 设置效果③的发动代价：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c57288708.thtg)
	e3:SetOperation(c57288708.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：检查怪兽是否是从额外卡组特殊召唤
function c57288708.tgfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：特殊召唤的怪兽组中存在从额外卡组特殊召唤的怪兽
function c57288708.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57288708.tgfilter,1,nil)
end
-- 效果①的发动代价：检查自身是否可以解放，并执行解放操作
function c57288708.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果①的靶向与操作信息注册：筛选出从额外卡组特殊召唤的怪兽并设为效果目标，注册送去墓地的操作信息
function c57288708.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c57288708.tgfilter,nil)
	-- 将从额外卡组特殊召唤的怪兽群设为本效果的目标
	Duel.SetTargetCard(g)
	-- 注册效果处理信息：将目标怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：将仍存在于场上的目标怪兽送去墓地
function c57288708.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c57288708.tgfilter,nil):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：通常召唤（非特殊召唤）的表侧表示的这张卡从怪兽区域离开场上
function c57288708.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and not c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤条件：卡名不为「星遗物-『星杯』」且可以特殊召唤的「星杯」怪兽
function c57288708.spfilter(c,e,tp)
	return c:IsSetCard(0xfd) and not c:IsCode(57288708) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向与操作信息注册：检查场上空位、精灵龙限制以及卡组中是否存在2只符合条件的怪兽，并注册特殊召唤的操作信息
function c57288708.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方场上的怪兽区域空位是否大于1个（因为需要特殊召唤2只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2只满足过滤条件的「星杯」怪兽
		and Duel.IsExistingMatchingCard(c57288708.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 注册效果处理信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择2只「星杯」怪兽以表侧表示特殊召唤
function c57288708.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择2只满足过滤条件的「星杯」怪兽
	local g=Duel.SelectMatchingCard(tp,c57288708.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
	if g:GetCount()==2 then
		-- 将选中的2只怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：可以加入手卡的「星遗物」卡
function c57288708.thfilter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 效果③的靶向与操作信息注册：检查卡组中是否存在可检索的「星遗物」卡，并注册检索的操作信息
function c57288708.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「星遗物」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c57288708.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组选择1张「星遗物」卡加入手卡，并给对方确认
function c57288708.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「星遗物」卡
	local g=Duel.SelectMatchingCard(tp,c57288708.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
