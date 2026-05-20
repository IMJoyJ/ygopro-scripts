--占い魔女 ヒカリちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合，以自己场上1只怪兽为对象才能发动。那只怪兽送去墓地，从卡组把1只魔法师族·1星怪兽特殊召唤。
function c6311717.initial_effect(c)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6311717,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,6311717)
	e1:SetCost(c6311717.spcost1)
	e1:SetTarget(c6311717.sptg1)
	e1:SetOperation(c6311717.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合，以自己场上1只怪兽为对象才能发动。那只怪兽送去墓地，从卡组把1只魔法师族·1星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6311717,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,6311718)
	e2:SetCondition(c6311717.spcon2)
	e2:SetTarget(c6311717.sptg2)
	e2:SetOperation(c6311717.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的Cost：确认这张卡在手卡且未给对方观看（未公开状态）
function c6311717.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①的Target：检查自身是否能特殊召唤以及怪兽区域是否有空位
function c6311717.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（将自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的Operation：将自身从手卡特殊召唤
function c6311717.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的Condition：检查这张卡是否是从手卡特殊召唤成功的
function c6311717.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 效果②的对象过滤条件：可以送去墓地，且该卡离开后自己场上有可用的怪兽区域
function c6311717.tgfilter2(c,tp)
	-- 过滤能送去墓地，且其离开后能腾出怪兽区域的卡片
	return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的特殊召唤过滤条件：卡组中的1星魔法师族怪兽
function c6311717.spfilter2(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target：选择自己场上1只怪兽作为对象，并确认卡组中存在可特殊召唤的怪兽
function c6311717.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToGrave() end
	-- 检查自己场上是否存在符合送去墓地条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(c6311717.tgfilter2,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查卡组中是否存在符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c6311717.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c6311717.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置从卡组特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation：将对象怪兽送去墓地，并从卡组特殊召唤1只魔法师族·1星怪兽
function c6311717.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送去墓地，并确认其已成功送去墓地
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
			-- 确认自己场上仍有可用的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组中选择1只符合条件的魔法师族·1星怪兽
			local g=Duel.SelectMatchingCard(tp,c6311717.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽以表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
