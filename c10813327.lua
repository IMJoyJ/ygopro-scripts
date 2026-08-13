--やぶ蛇
-- 效果：
-- ①：盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。从卡组·额外卡组把1只怪兽特殊召唤。
function c10813327.initial_effect(c)
	-- ①：盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。从卡组·额外卡组把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10813327,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c10813327.spcon)
	e1:SetTarget(c10813327.sptg)
	e1:SetOperation(c10813327.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
end
-- 发动条件判定：确认此卡是因对方的效果（rp==1-tp）从场上离开，且离场前位于我方场上、为背面表示（POS_FACEDOWN），满足‘盖放的这张卡因对方的效果从场上离开’的场合才能发动。
function c10813327.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 特殊召唤对象过滤：筛选可被此效果特殊召唤的怪兽，要求怪兽能特殊召唤（检查召唤条件和苏生限制），且位于卡组或额外卡组，并确保对应区域有空位。
function c10813327.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选怪兽在卡组：检查己方场上是否存在空闲的怪兽区域，确保能从卡组特殊召唤。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若候选怪兽在额外卡组：检查是否有可供额外卡组怪兽特殊召唤的可用怪兽区域（考虑额外卡组怪兽的出场位置限制）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 发动时目标选择：在效果发动时确认有至少1只符合条件的怪兽在卡组·额外卡组，并设置后续特殊召唤的操作信息。
function c10813327.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查（chk==0）：检索卡组·额外卡组中是否存在至少1只满足spfilter的怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c10813327.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：向系统声明本次效果将进行特殊召唤，对象来源为卡组·额外卡组，数量为1，用于连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理：由玩家从卡组·额外卡组选择1只符合条件的怪兽，将其特殊召唤到己方场上。
function c10813327.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：向操控玩家显示“请选择要特殊召唤的卡”的消息，用于引导选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组·额外卡组中选出1只满足spfilter条件的怪兽（自动过滤并限制选择范围）。
	local g=Duel.SelectMatchingCard(tp,c10813327.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上（sumtype为0，不跳过召唤条件和苏生限制检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
