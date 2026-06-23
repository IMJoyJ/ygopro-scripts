--王家の神殿
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己可以把1张陷阱卡在盖放的回合发动。
-- ②：把自己场上的表侧表示的1只「圣兽 塞勒凯特」和这张卡送去墓地才能发动。手卡·卡组1只怪兽或者额外卡组1只融合怪兽特殊召唤。
function c29762407.initial_effect(c)
	-- 记录该卡牌效果中涉及的其他卡名（圣兽 塞勒凯特）
	aux.AddCodeList(c,89194033)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己可以把1张陷阱卡在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29762407,1))  --"适用「王家的神殿」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1,29762407)
	c:RegisterEffect(e2)
	-- ②：把自己场上的表侧表示的1只「圣兽 塞勒凯特」和这张卡送去墓地才能发动。手卡·卡组1只怪兽或者额外卡组1只融合怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(29762407,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,29762408)
	e3:SetCost(c29762407.cost)
	e3:SetTarget(c29762407.target)
	e3:SetOperation(c29762407.operation)
	c:RegisterEffect(e3)
end
-- 检查场上是否存在满足条件的「圣兽 塞勒凯特」怪兽（正面表示、可送入墓地、且能发动效果）
function c29762407.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(89194033) and c:IsAbleToGraveAsCost()
		-- 检查是否存在满足条件的怪兽（手牌或卡组的怪兽或额外卡组的融合怪兽）可以被特殊召唤
		and Duel.IsExistingMatchingCard(c29762407.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,e:GetHandler()))
end
-- 判断是否满足发动条件（确认手牌或卡组中存在「圣兽 塞勒凯特」怪兽，且该卡能被送入墓地）
function c29762407.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		-- 确认场上存在满足条件的「圣兽 塞勒凯特」怪兽
		and Duel.IsExistingMatchingCard(c29762407.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「圣兽 塞勒凯特」怪兽
	local g=Duel.SelectMatchingCard(tp,c29762407.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 将选中的卡送入墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义可特殊召唤的怪兽过滤条件（手牌或卡组的怪兽或额外卡组的融合怪兽）
function c29762407.filter(c,e,tp,tg)
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsType(TYPE_FUSION))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断手牌或卡组的怪兽是否能被特殊召唤（需场上存在空怪兽区）
		and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) and Duel.GetMZoneCount(tp,tg)>0
			-- 判断额外卡组的融合怪兽是否能被特殊召唤（需额外卡组有可用召唤区域）
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,tg,c)>0)
end
-- 设置发动效果时的操作信息（准备特殊召唤怪兽）
function c29762407.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
-- 执行特殊召唤操作（选择并特殊召唤符合条件的怪兽）
function c29762407.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c29762407.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
