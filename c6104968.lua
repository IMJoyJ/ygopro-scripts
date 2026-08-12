--デスハムスター
-- 效果：
-- ①：这张卡反转的场合才能发动。从卡组把1只「死亡仓鼠」里侧守备表示特殊召唤。
function c6104968.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1只「死亡仓鼠」里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6104968,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c6104968.target)
	e1:SetOperation(c6104968.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上有空余的怪兽区域，且卡组中存在可以特殊召唤的「死亡仓鼠」
function c6104968.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c6104968.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡号为6104968（死亡仓鼠）且可以以里侧守备表示特殊召唤的怪兽
function c6104968.filter(c,e,tp)
	return c:IsCode(6104968) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理：从卡组将1只「死亡仓鼠」里侧守备表示特殊召唤，并给对方确认
function c6104968.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中第1张满足过滤条件的卡（死亡仓鼠）
	local tc=Duel.GetFirstMatchingCard(c6104968.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将该卡以里侧守备表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
