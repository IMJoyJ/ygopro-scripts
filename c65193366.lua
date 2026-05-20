--精霊獣使い ウィンダ
-- 效果：
-- 自己对「精灵兽使 薇茵妲」1回合只能有1次特殊召唤。
-- ①：这张卡被对方破坏的场合才能发动。从卡组·额外卡组把1只「灵兽」怪兽无视召唤条件特殊召唤。
function c65193366.initial_effect(c)
	c:SetSPSummonOnce(65193366)
	-- ①：这张卡被对方破坏的场合才能发动。从卡组·额外卡组把1只「灵兽」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65193366,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c65193366.spcon)
	e1:SetTarget(c65193366.sptg)
	e1:SetOperation(c65193366.spop)
	c:RegisterEffect(e1)
end
-- 检查是否是被对方卡片破坏，且破坏前由自己控制
function c65193366.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤卡组或额外卡组中可以无视召唤条件特殊召唤的「灵兽」怪兽，并检查是否有可用的怪兽区域
function c65193366.spfilter(c,e,tp)
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 若卡片在卡组，则需要自己场上有可用的怪兽区域
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，则需要有可用于从额外卡组特殊召唤该怪兽的怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果①的发动准备（检查是否存在可特殊召唤的卡，并设置特殊召唤的操作信息）
function c65193366.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的「灵兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65193366.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组或额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果①的效果处理（从卡组或额外卡组选择1只「灵兽」怪兽无视召唤条件特殊召唤）
function c65193366.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c65193366.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
