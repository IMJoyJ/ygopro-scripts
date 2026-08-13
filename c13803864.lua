--キング・もけもけ
-- 效果：
-- 「悠悠」＋「悠悠」＋「悠悠」
-- 这张卡从场上离开时，可以把自己墓地存在的「悠悠」尽可能多的特殊召唤。
function c13803864.initial_effect(c)
	c:EnableReviveLimit()
	-- 为悠悠王注册融合召唤手续：需要3只卡号为27288416的「悠悠」作为融合素材。
	aux.AddFusionProcCodeRep(c,27288416,3,true,true)
	-- “这张卡从场上离开时，可以把自己墓地存在的「悠悠」尽可能多的特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13803864,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(c13803864.spcon)
	e1:SetTarget(c13803864.sptg)
	e1:SetOperation(c13803864.spop)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤的「悠悠」的筛选条件：必须是卡号27288416的「悠悠」，且满足通常的特殊召唤条件。
function c13803864.spfilter(c,e,tp)
	return c:IsCode(27288416) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件：这只怪兽在离场前为表侧表示且位于场上。
function c13803864.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤目标判定：己方主要怪兽区有空位且墓地存在满足条件的「悠悠」时，可发动。
function c13803864.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：己方主要怪兽区必须存在至少1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地存在至少1只可特殊召唤的「悠悠」。
		and Duel.IsExistingMatchingCard(c13803864.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果操作信息：该效果含特殊召唤，从墓地特殊召唤「悠悠」；实际召唤数量在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从墓地尽可能多地特殊召唤「悠悠」，若场上适用「青眼精灵龙」的效果则最多特殊召唤1只。
function c13803864.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区的可用格子数，作为本次最多可特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取墓地中所有可特殊召唤的「悠悠」并组成集合。
	local tg=Duel.GetMatchingGroup(c13803864.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出提示，让玩家选择要特殊召唤的卡片（提示为“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	if g:GetCount()>0 then
		-- 将选中的「悠悠」以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
