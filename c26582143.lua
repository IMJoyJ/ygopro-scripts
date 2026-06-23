--剣闘獣ギステル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只「剑斗兽」怪兽给对方观看才能发动。那2只特殊召唤。
-- ②：这张卡用「剑斗兽」怪兽的效果特殊召唤的场合才能发动。从卡组把1张「剑斗」魔法·陷阱卡加入手卡。
-- ③：这张卡进行战斗的战斗阶段结束时，让这张卡回到卡组才能发动。从卡组把「剑斗兽 师斗」以外的1只「剑斗兽」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册三个效果：①特殊召唤、②检索魔陷、③战斗阶段结束时特殊召唤
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只「剑斗兽」怪兽给对方观看才能发动。那2只特殊召唤。
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
	-- ②：这张卡用「剑斗兽」怪兽的效果特殊召唤的场合才能发动。从卡组把1张「剑斗」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索魔陷"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	-- 效果条件：这张卡是用「剑斗兽」怪兽的效果特殊召唤的
	e2:SetCondition(aux.gbspcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时，让这张卡回到卡组才能发动。从卡组把「剑斗兽 师斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spcon2)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：手卡中满足「剑斗兽」属性、怪兽类型、未公开、可特殊召唤的卡
function s.costfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_GLADIATOR,tp,false,false)
end
-- 效果Cost：检查手卡是否存在满足条件的卡，并确认该卡未公开
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp)
		and not c:IsPublic() end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的卡
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 向对方确认所选卡
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- 效果Target：检查是否有足够的怪兽区和是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 过滤函数：满足效果关联、可特殊召唤的卡
function s.spopfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_GLADIATOR,tp,false,false)
end
-- 效果Operation：执行特殊召唤操作，将2只怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(s.spopfilter,nil,e,tp)
	if fg:GetCount()~=2 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 执行特殊召唤操作
	Duel.SpecialSummon(fg,SUMMON_VALUE_GLADIATOR,tp,tp,false,false,POS_FACEUP)
	-- 遍历特殊召唤的怪兽并注册FlagEffect
	for tc in aux.Next(fg) do
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
-- 过滤函数：卡组中满足「剑斗」属性、魔法·陷阱类型、可回手的卡
function s.thfilter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果Target：检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备回手1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果Operation：执行检索魔陷操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果Condition：战斗阶段结束时，该卡参与过战斗
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果Cost：将该卡送回卡组
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将该卡送回卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数：卡组中满足非本卡、剑斗兽属性、可特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果Target：检查卡组是否存在满足条件的卡
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果Operation：执行战斗阶段结束时的特殊召唤操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
