--大魔女サンドリヨン
local s,id,o=GetID()
-- 初始化效果，启用复活限制并设置融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为21522601的怪兽和2个魔法师族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,21522601,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),2,true,true)
	-- 效果1：融合召唤成功时发动，可以特殊召唤手牌或卡组中等级7以下的魔法使族怪兽
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
	-- 效果2：结束阶段时发动，可以从墓地特殊召唤自己
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
-- 效果1的发动条件：此卡为融合召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 筛选可特殊召唤的魔法使族怪兽，等级不超过7级
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的目标设定，检查是否有满足条件的怪兽可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果1的处理流程，获取场上空位数并选择符合条件的怪兽进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 then ft=1 end
	-- 获取满足条件的魔法使族怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从符合条件的怪兽中选择最多ft只且属性互不相同的怪兽组
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 将选中的怪兽组特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 注册一个回合结束时禁止特殊召唤融合怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤额外卡组中的融合怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果2的发动条件：当前为己方回合
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为己方回合
	return Duel.GetTurnPlayer()==tp
end
-- 筛选手牌中未公开的魔法卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 效果2的费用处理，选择一张未公开的手牌给对方确认并洗切手牌
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有未公开的魔法卡在手牌中
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张未公开的手牌
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将自己的手牌洗切
	Duel.ShuffleHand(tp)
end
-- 效果2的目标设定，检查是否可以特殊召唤自己
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示将要特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果2的处理流程，如果此卡在连锁中则特殊召唤到场上
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡以防守姿态特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
