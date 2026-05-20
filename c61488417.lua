--光竜星－リフン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「光龙星-螭吻」以外的1只「龙星」怪兽特殊召唤。
-- ②：这张卡在墓地存在，自己场上的「龙星」怪兽被战斗·效果破坏送去墓地时才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c61488417.initial_effect(c)
	-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「光龙星-螭吻」以外的1只「龙星」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61488417,0))  --"从卡组把「龙星」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,61488417)
	e1:SetCondition(c61488417.condition)
	e1:SetTarget(c61488417.target)
	e1:SetOperation(c61488417.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的「龙星」怪兽被战斗·效果破坏送去墓地时才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61488417,1))  --"这张卡从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,61488417)
	e2:SetCondition(c61488417.spcon)
	e2:SetTarget(c61488417.sptg)
	e2:SetOperation(c61488417.spop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否在自己场上被战斗或效果破坏并送去墓地
function c61488417.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤卡组中除「光龙星-螭吻」以外且可以特殊召唤的「龙星」怪兽
function c61488417.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(61488417) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位以及卡组中是否存在可特殊召唤的卡，并设置特殊召唤的操作信息
function c61488417.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的「龙星」怪兽
		and Duel.IsExistingMatchingCard(c61488417.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组选择1只「光龙星-螭吻」以外的「龙星」怪兽特殊召唤
function c61488417.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的「龙星」怪兽
	local g=Duel.SelectMatchingCard(tp,c61488417.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到发动效果玩家的场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤自己场上被战斗或效果破坏并送去墓地的「龙星」怪兽
function c61488417.cfilter(c,tp)
	return c:IsSetCard(0x9e) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 检查是否满足效果②的发动条件：自己场上的「龙星」怪兽被破坏送去墓地（且不包含这张卡自身）
function c61488417.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c61488417.cfilter,1,nil,tp)
end
-- 效果②的发动准备：检查怪兽区域空位以及自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c61488417.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息，表示此效果将特殊召唤这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将这张卡从墓地特殊召唤，并添加离场时除外的限制
function c61488417.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
