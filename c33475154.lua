--大魔女サンドリヨン
-- 效果：
-- 「魔女术师傅·玻璃女巫」＋魔法师族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从手卡·卡组把最多3只7星以下的「魔女术」怪兽特殊召唤（相同属性最多1只）。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的场合，自己结束阶段，把手卡1张魔法卡给对方观看才能发动。这张卡守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤手续，注册融合召唤成功时特召「魔女术」怪兽的效果以及在墓地自我特召的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：「魔女术师傅·玻璃女巫」＋魔法师族怪兽×2
	aux.AddFusionProcCodeFun(c,21522601,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),2,true,true)
	-- ①：这张卡融合召唤的场合才能发动。从手卡·卡组把最多3只7星以下的「魔女术」怪兽特殊召唤（相同属性最多1只）。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己结束阶段，把手卡1张魔法卡给对方观看才能发动。这张卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判定卡片是否通过融合召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤可以特殊召唤的7星以下的「魔女术」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与目标设置：判定手卡·卡组是否存在可特殊召唤的7星以下「魔女术」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己主要怪兽区是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡·卡组中是否存在满足条件的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡·卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的处理：从手卡·卡组把最多3只不同属性的7星以下「魔女术」怪兽特殊召唤，并附加额外卡组召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区的空余位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 then ft=1 end
	-- 获取手卡·卡组中满足条件的「魔女术」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择最多3只属性互不相同的「魔女术」怪兽
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
		if sg then
			-- 将选择的「魔女术」怪兽表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对自身玩家注册不能从额外卡组特殊召唤融合怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤融合怪兽以外的怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 判定当前是否为自己的回合
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自身
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中未公开的魔法卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- ②效果的Cost处理：把手卡1张魔法卡给对方观看
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手卡是否存在未公开的魔法卡作为Cost
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡1张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的魔法卡给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- ②效果的目标判定：判定自身是否能守备表示特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定自己主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理：将墓地的自身守备表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自身是否与连锁相关且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
