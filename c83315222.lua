--BK プロモーター
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。
-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从卡组把「燃烧拳击手 推广人」以外的最多2只「燃烧拳击手」怪兽特殊召唤（同名卡最多1张）。
-- ③：把墓地的这张卡除外才能发动。自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
function c83315222.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83315222,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,83315222)
	e1:SetCondition(c83315222.spcon)
	e1:SetCost(c83315222.cost)
	e1:SetTarget(c83315222.sptg1)
	e1:SetOperation(c83315222.spop1)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从卡组把「燃烧拳击手 推广人」以外的最多2只「燃烧拳击手」怪兽特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83315222,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,83315223)
	e2:SetCost(c83315222.spcost)
	e2:SetTarget(c83315222.sptg2)
	e2:SetOperation(c83315222.spop2)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83315222,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,83315224)
	e3:SetCost(c83315222.lvcost)
	e3:SetTarget(c83315222.lvtg)
	e3:SetOperation(c83315222.lvop)
	c:RegisterEffect(e3)
	-- 注册一个自定义活动计数器，用于检测本回合是否特殊召唤了非「燃烧拳击手」怪兽。
	Duel.AddCustomActivityCounter(83315222,ACTIVITY_SPSUMMON,c83315222.counterfilter)
end
-- 定义计数器的过滤条件，用于判定特殊召唤的怪兽是否为「燃烧拳击手」怪兽。
function c83315222.counterfilter(c)
	return c:IsSetCard(0x1084) and c:IsFaceup()
end
-- 定义效果发动的Cost处理函数，用于检查并适用本回合不能特殊召唤「燃烧拳击手」以外怪兽的限制。
function c83315222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在Cost检查阶段，确认本回合此前是否未特殊召唤过非「燃烧拳击手」怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(83315222,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是「燃烧拳击手」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c83315222.splimit)
	e1:SetLabelObject(e)
	-- 在全局环境中注册限制玩家特殊召唤非「燃烧拳击手」怪兽的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制的过滤条件，禁止特殊召唤非「燃烧拳击手」怪兽。
function c83315222.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1084)
end
-- 定义效果①的发动条件检查函数。
function c83315222.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在怪兽。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 定义效果①的目标选择与合法性检查函数。
function c83315222.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息，用于连锁处理的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义效果①的效果处理函数。
function c83315222.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②的Cost处理函数，包含解放自身和适用特殊召唤限制。
function c83315222.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		and c83315222.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 解放自身作为效果发动的Cost。
	Duel.Release(c,REASON_COST+REASON_RELEASE)
	c83315222.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 定义效果②的特殊召唤怪兽过滤条件，筛选卡组中「燃烧拳击手 推广人」以外的「燃烧拳击手」怪兽。
function c83315222.spfilter(c,e,tp)
	return c:IsSetCard(0x1084) and not c:IsCode(83315222) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果②的目标选择与合法性检查函数。
function c83315222.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡解放后，自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「燃烧拳击手」怪兽。
		and Duel.IsExistingMatchingCard(c83315222.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置从卡组特殊召唤怪兽的操作信息，用于连锁处理的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的效果处理函数。
function c83315222.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前最多可以特殊召唤的怪兽数量（最多2只且不超过空余怪兽区域数）。
	local ft=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有满足特殊召唤条件的「燃烧拳击手」怪兽组。
	local g=Duel.GetMatchingGroup(c83315222.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 向玩家发送选择特殊召唤怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从符合条件的怪兽中选择1到ft只卡名不同的怪兽。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if sg then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果③的Cost处理函数，包含除外自身和适用特殊召唤限制。
function c83315222.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and c83315222.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 将墓地的这张卡除外作为效果发动的Cost。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	c83315222.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 定义效果③的等级变更对象过滤条件，筛选自己场上表侧表示且有等级的「燃烧拳击手」怪兽。
function c83315222.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:IsLevelAbove(1)
end
-- 定义效果③的目标选择与合法性检查函数。
function c83315222.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足等级变更条件的「燃烧拳击手」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c83315222.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义效果③的效果处理函数。
function c83315222.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足等级变更条件的「燃烧拳击手」怪兽组。
	local g=Duel.GetMatchingGroup(c83315222.lvfilter,tp,LOCATION_MZONE,0,nil)
	local sel=0
	local lv=1
	if not g:IsExists(Card.IsLevelAbove,1,nil,2) then
		-- 若场上怪兽等级都为1（无法再下降），则强制选择“等级上升”选项。
		sel=Duel.SelectOption(tp,aux.Stringid(83315222,3))  --"等级上升"
	else
		-- 让玩家选择“等级上升”或“等级下降”的操作。
		sel=Duel.SelectOption(tp,aux.Stringid(83315222,3),aux.Stringid(83315222,4))  --"等级上升/等级下降"
	end
	if sel==1 then
		lv=-1
	end
	-- 遍历所有符合等级变更条件的怪兽。
	for tc in aux.Next(g) do
		-- 自己场上的「燃烧拳击手」怪兽的等级全部上升1星或全部下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
