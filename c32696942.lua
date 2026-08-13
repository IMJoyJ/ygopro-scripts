--三段腹ナイト
-- 效果：
-- 超量素材的这张卡为让超量怪兽把效果发动而被取除送去墓地的场合，可以从手卡把1只3星以下的怪兽特殊召唤。
function c32696942.initial_effect(c)
	-- 超量素材的这张卡为让超量怪兽把效果发动而被取除送去墓地的场合，可以从手卡把1只3星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32696942,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c32696942.spcon)
	e1:SetTarget(c32696942.sptg)
	e1:SetOperation(c32696942.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：获取效果所属的这张卡，确认它是因为超量怪兽发动效果而被取除并送去墓地（原因为代价、发动效果为怪兽效果、且这张卡之前位于超量素材区域）。
function c32696942.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 特殊召唤候选的过滤函数：手卡中等级3以下且可以被当前效果特殊召唤的怪兽。
function c32696942.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标阶段：确认自己主要怪兽区有空位，且手卡中存在至少1只满足特殊召唤条件的怪兽，才允许发动。
function c32696942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件（3星以下且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c32696942.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将要进行特殊召唤，预定从手卡特殊召唤1只怪兽，供后续效果检测和连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：若仍有主怪兽区空位，则从手卡选择1只满足条件的怪兽，以表侧表示特殊召唤到自己场上。
function c32696942.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前再次确认主怪兽区还有空位，若无空位则直接终止本次处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示消息，让玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足特殊召唤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c32696942.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
