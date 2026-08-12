--大皇帝ペンギン
-- 效果：
-- ①：把这张卡解放才能发动。从卡组把「大皇帝企鹅」以外的最多2只「企鹅」怪兽特殊召唤。
function c6836211.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把「大皇帝企鹅」以外的最多2只「企鹅」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6836211,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c6836211.spcost)
	e1:SetTarget(c6836211.sptg)
	e1:SetOperation(c6836211.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价（Cost），检查并解放自身。
function c6836211.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中「大皇帝企鹅」以外且可以特殊召唤的「企鹅」怪兽。
function c6836211.filter(c,e,tp)
	return c:IsSetCard(0x5a) and not c:IsCode(6836211) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动的目标（Target），检查怪兽区域空位及卡组中是否存在可特殊召唤的怪兽，并设置操作信息。
function c6836211.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查怪兽区域的空位数（由于自身解放，空位数需大于-1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c6836211.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理（Operation），计算可召唤数量并从卡组特殊召唤最多2只「企鹅」怪兽。
function c6836211.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1到ft张（最多2张）满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c6836211.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
