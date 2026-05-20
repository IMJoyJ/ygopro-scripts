--鰤っ子姫
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时，把这张卡除外才能发动。从卡组把「鰤子姬」以外的1只4星以下的鱼族怪兽特殊召唤。
function c6625096.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，把这张卡除外才能发动。从卡组把「鰤子姬」以外的1只4星以下的鱼族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6625096,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,6625096)
	e1:SetCost(c6625096.spcost)
	e1:SetTarget(c6625096.sptg)
	e1:SetOperation(c6625096.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果发动代价（Cost）处理：检查自身是否可以作为代价除外，并将自身表侧表示除外
function c6625096.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身作为发动代价表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中「鰤子姬」以外的4星以下的鱼族怪兽，且可以被特殊召唤
function c6625096.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH) and not c:IsCode(6625096) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动准备（Target）处理：检查怪兽区域空位以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c6625096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（由于自身作为代价除外，场上会多出一个空位，因此可用空位数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c6625096.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）处理：在怪兽区域有空位的情况下，从卡组选择1只符合条件的怪兽特殊召唤
function c6625096.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c6625096.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
