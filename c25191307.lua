--RR－ブルーム・ヴァルチャー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是暗属性怪兽不能特殊召唤。
-- ①：自己场上没有鸟兽族怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡和1只「急袭猛禽」怪兽从手卡特殊召唤。
-- ②：自己场上没有怪兽存在的场合，以包含这张卡的自己墓地2只4星以下的「急袭猛禽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 创建两个起动效果，分别对应手牌和墓地的特殊召唤效果
function s.initial_effect(c)
	-- ①：自己场上没有鸟兽族怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡和1只「急袭猛禽」怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，以包含这张卡的自己墓地2只4星以下的「急袭猛禽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录本回合特殊召唤的次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，仅对暗属性怪兽计数
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤函数，用于检测场上是否存在非鸟兽族的表侧表示怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_WINDBEAST)
end
-- 效果条件函数，判断场上是否没有鸟兽族以外的表侧表示怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场上没有鸟兽族以外的表侧表示怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果的费用，检查是否为本回合第一次特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册一个影响玩家的永续效果，禁止非暗属性怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将费用效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 费用效果的限制函数，禁止非暗属性怪兽特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤函数，用于检测手牌中是否含有「急袭猛禽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标，检查是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 手牌中存在「急袭猛禽」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤2张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 执行效果的处理函数，从手牌特殊召唤该卡和1只「急袭猛禽」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手牌中的「急袭猛禽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选中的卡和该卡一起特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件函数，判断自己场上是否没有怪兽
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数，用于检测墓地中的「急袭猛禽」怪兽（4星以下）
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xba) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的目标，检查是否满足墓地特殊召唤条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
		-- 墓地中存在符合条件的「急袭猛禽」怪兽
		and c:IsCanBeEffectTarget(e) and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「急袭猛禽」怪兽
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	g:AddCard(c)
	-- 设置连锁的目标卡
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息，表示将特殊召唤2张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,LOCATION_GRAVE)
end
-- 执行效果的处理函数，从墓地守备表示特殊召唤2只「急袭猛禽」怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	-- 获取当前连锁相关的对象卡
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将对象卡以守备表示特殊召唤
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
