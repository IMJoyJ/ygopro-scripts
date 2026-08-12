--ドラグマ・エンカウンター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只「教导」怪兽或「阿不思的落胤」特殊召唤。
-- ●从自己墓地选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c29354228.initial_effect(c)
	-- 记录该卡牌效果中涉及的「阿不思的落胤」卡号
	aux.AddCodeList(c,68468459)
	-- ①：可以从以下效果选择1个发动。●从手卡把1只「教导」怪兽或「阿不思的落胤」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29354228,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,29354228+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c29354228.sptg)
	e1:SetOperation(c29354228.spop)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。●从自己墓地选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29354228,1))  --"从墓地加入手卡或特殊召唤"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,29354228+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(c29354228.thtg)
	e2:SetOperation(c29354228.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中满足条件的「教导」怪兽或「阿不思的落胤」怪兽，用于特殊召唤
function c29354228.spfilter(c,e,tp)
	return (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足手卡特殊召唤的发动条件
function c29354228.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡特殊召唤时场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c29354228.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示对方玩家选择了效果①的第1个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理手卡特殊召唤的效果
function c29354228.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择满足条件的1只怪兽用于特殊召唤
	local g=Duel.SelectMatchingCard(tp,c29354228.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤墓地中满足条件的「教导」怪兽或「阿不思的落胤」怪兽，用于加入手卡或特殊召唤
function c29354228.thfilter(c,e,tp)
	if not (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取场上可用于特殊召唤的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 判断是否满足墓地加入手卡或特殊召唤的发动条件
function c29354228.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29354228.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示对方玩家选择了效果①的第2个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为墓地特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息为墓地加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 处理墓地加入手卡或特殊召唤的效果
function c29354228.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从墓地中选择满足条件的1只怪兽用于处理
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29354228.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取场上可用于特殊召唤的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择将怪兽加入手卡或特殊召唤
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方玩家看到该怪兽加入手卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
