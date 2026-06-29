--大魔女サンドリヨン
local s,id,o=GetID()
-- 注册融合召唤条件、融合特召时从手牌或卡组特召最多3只魔女工艺怪兽、以及结束阶段通过展示手牌魔法特召自身的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册融合召唤的素材要求规程
	aux.AddFusionProcCodeFun(c,21522601,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),2,true,true)
	-- ①::这张卡融合召唤成功的场合才能发动。从手卡·卡组把最多3只等级7以下的「魔女工艺」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能作为融合素材以外的额外卡组怪兽特殊召唤的素材，这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
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
	-- ②：自己结束阶段，这张卡在墓地存在的场合，从手卡把1张魔法卡给对方观看才能发动。这张卡在自己场上守备表示特殊召唤。
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
-- 确认此卡是否是通过融合召唤的方式特殊召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 可特殊召唤的7星以下「魔女工艺」怪兽过滤条件
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤多只「魔女工艺」怪兽效果的发动准备
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡和卡组中是否存在可特殊召唤的「魔女工艺」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从手牌或卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤「魔女工艺」怪兽及后续额外召唤限制效果的执行与注册
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可以特殊召唤怪兽的最大场上区域空间
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 then ft=1 end
	-- 获取手牌和卡组中所有满足条件的「魔女工艺」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 向玩家发送提示，请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌或卡组选择最多符合区域空位限制的魔女工艺怪兽
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 特殊召唤选中的魔女工艺怪兽们
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果特殊召唤的怪兽在这个回合不能作为融合素材以外的额外卡组怪兽特殊召唤的素材，这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册本回合只能从额外卡组特殊召唤融合怪兽的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制非融合怪兽从额外卡组特殊召唤的条件
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 结束阶段效果在自己回合结束阶段的发动条件判断
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前正处于自己的结束阶段
	return Duel.GetTurnPlayer()==tp
end
-- 手牌中可用于展示的未公开魔法卡的过滤条件
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 从手牌展示魔法卡以发动特召效果的代价执行
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在未公开的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送提示，请选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择1张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方展示选中的魔法卡
	Duel.ConfirmCards(1-tp,g)
	-- 重新将自己的手牌洗牌
	Duel.ShuffleHand(tp)
end
-- 墓地特召自身效果的发动准备
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空闲怪兽区域以及自身是否能在墓地发动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息为将墓地的此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 墓地特召自身效果的执行
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡依然合法存在于墓地且未受无效影响，则继续处理
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以守备表示特殊召唤此卡
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
