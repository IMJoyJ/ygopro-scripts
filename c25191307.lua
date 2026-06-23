--RR－ブルーム・ヴァルチャー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是暗属性怪兽不能特殊召唤。
-- ①：自己场上没有鸟兽族怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡和1只「急袭猛禽」怪兽从手卡特殊召唤。
-- ②：自己场上没有怪兽存在的场合，以包含这张卡的自己墓地2只4星以下的「急袭猛禽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册手卡特殊召唤自身与另外1只急袭猛禽怪兽的效果①，墓地守备表示特殊召唤包含自身的2只4星以下急袭猛禽怪兽的效果②，并注册用于限制暗属性外怪兽特殊召唤的计数器
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
	-- 添加自定义计数器，用于监控玩家在这一回合中是否特殊召唤过暗属性怪兽以外的怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数：检测特殊召唤的怪兽是否为表侧表示的暗属性怪兽
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
-- 过滤函数：检测场上是否存在表侧表示的非鸟兽族怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_WINDBEAST)
end
-- 效果①的发动条件：自己场上没有鸟兽族怪兽以外的表侧表示怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上不存在鸟兽族怪兽以外的表侧表示怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动的代价：确认本回合玩家未特殊召唤过暗属性以外的怪兽，并在发动时注册限制本回合只能特殊召唤暗属性怪兽的誓约效果
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检测时，检查本回合是否未特殊召唤过暗属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，这些效果发动的回合，自己不是暗属性怪兽不能特殊召唤。①：自己场上没有鸟兽族怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡和1只「急袭猛禽」怪兽从手卡特殊召唤。②：自己场上没有怪兽存在的场合，以包含这张卡的自己墓地2只4星以下的「急袭猛禽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动效果的玩家注册誓约限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 誓约效果的限制过滤：自己不能特殊召唤暗属性以外的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤函数：检测手卡中可被特殊召唤的「急袭猛禽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与检测：检查自己主要怪兽区域是否有2个以上的空位、青眼精灵龙的效果是否未适用，以及这张卡和手卡另一只「急袭猛禽」怪兽是否均能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断手卡中是否存在除了这张卡以外的可特殊召唤的「急袭猛禽」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 设置效果处理信息：从手卡特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 效果①的效果处理：在满足特殊召唤位置与不受青眼精灵龙限制的情况下，将这张卡与玩家选择的1只手卡「急袭猛禽」怪兽特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 在客户端向玩家显示选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足特殊召唤条件的「急袭猛禽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选择的「急袭猛禽」怪兽与这张卡一起表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：自己场上没有怪兽存在
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数：检测墓地中可被守备表示特殊召唤的4星以下「急袭猛禽」怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xba) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与检测：在chk==0时检测自己怪兽区是否有2个以上空位、精灵龙未适用、墓地中的这张卡与另一只4星以下「急袭猛禽」怪兽均可作为对象并特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
		-- 判断这张卡是否能作为效果对象，且墓地中存在另一只可作为效果对象的4星以下「急袭猛禽」怪兽
		and c:IsCanBeEffectTarget(e) and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 在客户端向玩家显示选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中1只除这张卡以外的4星以下「急袭猛禽」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	g:AddCard(c)
	-- 将选择的怪兽与墓地中的这张卡一同设定为当前效果的影响对象
	Duel.SetTargetCard(g)
	-- 设置效果处理信息：从墓地特殊召唤这2只作为对象的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,LOCATION_GRAVE)
end
-- 效果②的效果处理：在满足特召空位与不受精灵龙效果影响时，将墓地中作为对象的2只怪兽守备表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	-- 获取墓地中仍与当前效果链关联的对象怪兽
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将作为对象的这2只怪兽以守备表示特殊召唤
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
