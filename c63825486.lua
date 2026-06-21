--ギミック・パペット－ブラッディ・ドール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。
-- ①：这张卡在手卡存在的场合，把额外卡组1只「机关傀儡」超量怪兽给对方观看才能发动。把持有和给人观看的怪兽的阶级相同数值的等级的卡组1只「机关傀儡」怪兽和这张卡特殊召唤。
-- ②：这张卡从手卡以外送去墓地的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果并添加自定义活动计数器
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，把额外卡组1只「机关傀儡」超量怪兽给对方观看才能发动。把持有和给人观看的怪兽的阶级相同数值的等级的卡组1只「机关傀儡」怪兽和这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡以外送去墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 添加用于检测额外卡组特殊召唤限制的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，用于检测是否特殊召唤了非「机关傀儡」的额外卡组怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x1083) and c:IsFaceup()
end
-- 效果①的Cost函数，包含检查特殊召唤限制、展示额外卡组怪兽并注册誓约效果
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未特殊召唤过非「机关傀儡」的额外卡组怪兽，以及额外卡组是否存在可展示的「机关傀儡」超量怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择要确认（展示）的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组中选择1只满足条件的「机关傀儡」超量怪兽
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,sc)
	e:SetLabel(sc:GetRank())
	-- 这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册不能特殊召唤非「机关傀儡」额外卡组怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非「机关傀儡」额外卡组怪兽的过滤函数
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x1083)
end
-- 额外卡组「机关傀儡」超量怪兽的过滤条件：阶级在1以上，且卡组中存在相同等级的「机关傀儡」怪兽
function s.spfilter(c,e,tp)
	-- 过滤条件：是「机关傀儡」怪兽、阶级在1以上，且卡组中存在持有相同数值等级的、可特殊召唤的「机关傀儡」怪兽
	return c:IsSetCard(0x1083) and c:IsRankAbove(1) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRank())
end
-- 卡组「机关傀儡」怪兽的过滤条件：是「机关傀儡」怪兽、等级与展示怪兽的阶级相同，且可以特殊召唤
function s.spfilter2(c,e,tp,lv)
	return c:IsSetCard(0x1083) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Target函数，检查怪兽区域空格、自身是否可特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（从手卡和卡组特殊召唤2只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的Operation函数，将卡组中1只对应等级的「机关傀儡」怪兽和手卡的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not c:IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,59822133) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 再次确认自己场上的怪兽区域是否有2个以上的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只持有与给人观看的怪兽阶级相同数值等级的「机关傀儡」怪兽
		local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv):GetFirst()
		if tc then
			-- 准备将手卡的这张卡以表侧表示特殊召唤
			Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
			-- 准备将选中的卡组怪兽以表侧表示特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 完成上述两只怪兽的特殊召唤
			Duel.SpecialSummonComplete()
		end
	end
end
-- 效果②的Condition函数，检查这张卡是否是从手卡以外送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_HAND)
end
-- 效果②的Cost函数，包含检查特殊召唤限制并注册誓约效果
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未特殊召唤过非「机关傀儡」的额外卡组怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册不能特殊召唤非「机关傀儡」额外卡组怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的Target函数，检查这张卡是否可以加入手卡，并设置回收的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置将这张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果②的Operation函数，将墓地的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
