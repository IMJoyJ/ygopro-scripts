--フラッピィ
-- 效果：
-- 这张卡召唤成功时，可以从卡组把1只「冰沙怪」送去墓地。此外，自己墓地的「冰沙怪」以及从游戏中除外的自己的「冰沙怪」的合计是3只的场合，把墓地的这张卡从游戏中除外才能发动。选择自己墓地1只海龙族·5星以上的怪兽特殊召唤。「冰沙怪」的这个效果1回合只能使用1次。
function c84650463.initial_effect(c)
	-- 这张卡召唤成功时，可以从卡组把1只「冰沙怪」送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84650463,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c84650463.target)
	e1:SetOperation(c84650463.operation)
	c:RegisterEffect(e1)
	-- 此外，自己墓地的「冰沙怪」以及从游戏中除外的自己的「冰沙怪」的合计是3只的场合，把墓地的这张卡从游戏中除外才能发动。选择自己墓地1只海龙族·5星以上的怪兽特殊召唤。「冰沙怪」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84650463,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,84650463)
	e2:SetCondition(c84650463.spcon)
	-- 将墓地的这张卡除外作为发动的Cost（代价）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c84650463.sptg)
	e2:SetOperation(c84650463.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中卡名为「冰沙怪」且能送去墓地的卡
function c84650463.tgfilter(c)
	return c:IsCode(84650463) and c:IsAbleToGrave()
end
-- 召唤成功时效果的发动准备与检测
function c84650463.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以送去墓地的「冰沙怪」
	if chk==0 then return Duel.IsExistingMatchingCard(c84650463.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 召唤成功时效果的处理：从卡组选择1只「冰沙怪」送去墓地
function c84650463.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「冰沙怪」
	local g=Duel.SelectMatchingCard(tp,c84650463.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤墓地或除外区中表侧表示的「冰沙怪」
function c84650463.cfilter(c)
	return c:IsCode(84650463) and c:IsFaceup()
end
-- 特殊召唤效果的发动条件判定
function c84650463.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地和除外区的「冰沙怪」合计数量是否刚好为3只
	return Duel.GetMatchingGroupCount(c84650463.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)==3
end
-- 过滤墓地中等级5以上且可以特殊召唤的海龙族怪兽
function c84650463.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsRace(RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标选择
function c84650463.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c84650463.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己墓地是否存在至少1只可以作为对象特殊召唤的、除自身以外的满足条件的怪兽
		and Duel.IsExistingTarget(c84650463.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c84650463.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁处理的操作信息为：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理：将选择的怪兽特殊召唤
function c84650463.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
