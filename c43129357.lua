--蕾禍ノ武者髑髏
-- 效果：
-- 包含昆虫族·植物族·爬虫类族怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
-- ①：以自己墓地1只「蕾祸」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：添加连接召唤手续，注册效果①（墓地特殊召唤「蕾祸」怪兽）和效果②（墓地自我特殊召唤），并设置特殊召唤计数器。
function s.initial_effect(c)
	-- 连接召唤条件：包含昆虫族·植物族·爬虫类族怪兽的怪兽2只。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只「蕾祸」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤「蕾祸」怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤自身"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 设置自定义特殊召唤计数器，用来检测玩家本回合是否特殊召唤了昆虫族、植物族、爬虫类族以外的怪兽。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 自定义计数器过滤：判断被特殊召唤的怪兽是否是表侧表示的昆虫族、植物族或爬虫类族怪兽。
function s.counterfilter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsFaceup()
end
-- 连接素材检测：素材怪兽中必须包含至少1只昆虫族、植物族或爬虫类族怪兽。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- 效果发动条件及代价：确认本回合玩家没有特殊召唤过昆虫/植物/爬虫类以外的怪兽，并在发动后施加本回合不能特殊召唤那些种族以外的怪兽的自誓限制。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检测玩家本回合是否已特殊召唤过非昆虫族·植物族·爬虫类族怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。①：以自己墓地1只「蕾祸」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能特殊召唤昆虫族·植物族·爬虫类族以外怪兽的自誓效果限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自誓限制的具体过滤：限制特殊召唤不是昆虫族、植物族、爬虫类族的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- 效果①特殊召唤对象的过滤：选择自己墓地中可以特殊召唤的「蕾祸」怪兽。
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x1ab) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备：以自己墓地1只「蕾祸」怪兽为对象发动，并设置特殊召唤的操作信息。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
	-- 检测玩家的怪兽区是否有空位，以及墓地中是否有可以特殊召唤的「蕾祸」对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置玩家选择特殊召唤对象时的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地中的1只「蕾祸」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的效果操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的「蕾祸」怪兽在自己场上以守备表示特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以守备表示特殊召唤到玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②返回卡组怪兽的过滤：必须是自己场上表侧表示的昆虫族·植物族·爬虫类族怪兽，且返回卡组后能腾出空余怪兽区以供这张卡特殊召唤。
function s.tdfilter(c,tp)
	-- 判定目标怪兽是否是表侧表示的昆虫/植物/爬虫类族，且能够返回卡组，且离场后有空位特殊召唤此卡。
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToDeck()
end
-- 效果②的发动准备：确认自己场上是否有满足返回卡组条件的怪兽，以及墓地中的这张卡能否特殊召唤，并进行取对象和效果信息注册。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tdfilter(chkc,tp) end
	-- 在效果发动时检测场上是否存在满足返回卡组条件的对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置玩家选择返回卡组怪兽时的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择场上的1只昆虫族·植物族·爬虫类族怪兽作为返回卡组的对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置将怪兽送回卡组的效果操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置特殊召唤墓地这张卡的效果操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将对象怪兽返回卡组最下面，成功后如果自己场上有空位且这张卡在墓地，则将这张卡特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的场上怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然符合条件，并将其送回持有者卡组的最下面。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 确认将怪兽返回卡组成功后，自己场上是否有空余怪兽区，以及墓地中的这张卡是否仍受到效果影响。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
