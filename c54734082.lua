--マグネット・インダクション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有原本等级是4星以下的「磁石战士」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只4星以下的「磁石战士」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己场上的「磁石战士」怪兽不会被战斗以及对方的效果破坏。
function c54734082.initial_effect(c)
	-- ①：自己场上有原本等级是4星以下的「磁石战士」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只4星以下的「磁石战士」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己场上的「磁石战士」怪兽不会被战斗以及对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,54734082+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c54734082.spcon)
	e1:SetTarget(c54734082.sptg)
	e1:SetOperation(c54734082.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、原本等级在4星以下的「磁石战士」怪兽
function c54734082.cpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2066) and c:GetOriginalLevel()<=4
end
-- 发动条件：检查自己场上是否存在原本等级在4星以下的「磁石战士」怪兽
function c54734082.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示且原本等级在4星以下的「磁石战士」怪兽
	return Duel.IsExistingMatchingCard(c54734082.cpfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己场上表侧表示且卡名与指定卡名相同的卡
function c54734082.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤条件：卡组中可以特殊召唤的、4星以下的「磁石战士」怪兽，且其同名卡不在自己场上存在
function c54734082.spfilter(c,e,tp)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且自己场上不存在同名卡
		and not Duel.IsExistingMatchingCard(c54734082.cfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
-- 效果发动准备（Target）：检查怪兽区域空位以及卡组中是否存在可特殊召唤的合法怪兽，并设置特殊召唤的操作信息
function c54734082.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在至少1只满足特殊召唤条件的「磁石战士」怪兽
		and Duel.IsExistingMatchingCard(c54734082.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）：注册直到回合结束时自己场上「磁石战士」怪兽不会被战斗和效果破坏的永续效果，并从卡组特殊召唤1只满足条件的「磁石战士」怪兽
function c54734082.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 同名卡不在自己场上存在的1只4星以下的「磁石战士」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己场上的「磁石战士」怪兽不会被战斗以及对方的效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTarget(c54734082.indtg)
		e1:SetValue(1)
		-- 注册战斗破坏抗性效果给玩家
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置效果破坏抗性仅对对方的效果有效
		e2:SetValue(aux.indoval)
		-- 注册效果破坏抗性效果给玩家
		Duel.RegisterEffect(e2,tp)
	end
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「磁石战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c54734082.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏抗性效果的目标过滤：自己场上表侧表示的「磁石战士」怪兽
function c54734082.indtg(e,c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x2066) or c:IsSetCard(0xe9)) and c:IsFaceup()
end
