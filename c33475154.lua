--大魔女サンドリヨン
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合素材：怪兽「21522601」＋魔法师族怪兽2只
	aux.AddFusionProcCodeFun(c,21522601,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),2,true,true)
	-- ①：这张卡融合召唤成功的场合才能发动。从手卡·卡组把最多3只等级7以下的「魔女术」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己从额外卡组只能特殊召唤融合怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段，把手卡1张魔法卡给对方观看才能发动。这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
-- 触发条件：必须是通过融合召唤特殊召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤手卡或卡组中等级7以下的「魔女术」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①特殊召唤条件检查与声明
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否存在怪兽位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌或卡组中是否存在可以特召的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 声明从手牌与卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的实际操作：特召最多3只魔女术怪兽，并注册额外卡组特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方场上的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 then ft=1 end
	-- 获取手牌和卡组中所有的魔女术怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 提示选择特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择最多3只非同名的魔女术怪兽进行特殊召唤
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 限制本回合额外卡组特殊召唤的种类
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的过滤器：禁止特殊召唤除融合怪兽以外的额外卡组怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 触发条件：必须在自己的结束阶段
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否为我方的回合
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中的魔法卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 效果②的Cost：展示手牌中的1张魔法卡
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手牌中的1张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认该魔法卡
	Duel.ConfirmCards(1-tp,g)
	-- 将手牌洗牌
	Duel.ShuffleHand(tp)
end
-- 效果②特殊召唤条件检查
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自己场上是否存在怪兽位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 声明将本卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的实际操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
