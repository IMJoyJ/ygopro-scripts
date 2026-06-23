--蕾禍ノ大王鬼牙
-- 效果：
-- 昆虫族·植物族·爬虫类族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从对方的卡组·额外卡组有怪兽特殊召唤的场合才能发动。场上2只怪兽破坏。
-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤条件并启用复活限制
function s.initial_effect(c)
	-- 设置连接召唤需要2到5只同时具有昆虫族、植物族、爬虫类族种族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_INSECT+RACE_PLANT+RACE_REPTILE),2,5)
	c:EnableReviveLimit()
	-- 效果①：从对方的卡组·额外卡组有怪兽特殊召唤的场合才能发动，场上2只怪兽破坏
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.decon)
	e1:SetTarget(s.detg)
	e1:SetOperation(s.deop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动，那只怪兽回到卡组最下面，这张卡特殊召唤，且此回合不能特殊召唤非昆虫族·植物族·爬虫类族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断是否为从对方卡组或额外卡组特殊召唤的怪兽
function s.defilter(c,tp)
	return c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 判断是否有从对方卡组或额外卡组特殊召唤的怪兽
function s.decon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.defilter,1,nil,tp)
end
-- 设置效果①的发动时点，检查场上是否存在至少2只怪兽
function s.detg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少2只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	-- 获取场上所有怪兽的集合
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，表示将破坏2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果①的处理函数，选择并破坏2只怪兽
function s.deop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有怪兽的集合
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()<2 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择2只怪兽作为破坏对象
	local sg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
	if sg:GetCount()==2 then
		-- 显示选中卡的动画效果
		Duel.HintSelection(sg)
		-- 将选中的怪兽破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 定义过滤函数，用于判断是否可以送回卡组的昆虫族·植物族·爬虫类族怪兽
function s.spfilter(c,tp)
	-- 判断怪兽是否在场、是昆虫族·植物族·爬虫类族、且可以送回卡组
	return Duel.GetMZoneCount(tp,c)>0 and c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeck()
end
-- 设置效果②的发动条件，检查是否有符合条件的怪兽可选且自身可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc,tp) end
	-- 检查是否有符合条件的怪兽可选
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1只怪兽作为送回卡组的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息，表示将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理函数，将目标怪兽送回卡组并特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且已送回卡组
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 判断是否有足够的怪兽区且自身有效
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置永续效果，禁止在本回合内特殊召唤非昆虫族·植物族·爬虫类族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该永续效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义禁止特殊召唤的过滤函数，判断怪兽是否不具有昆虫族·植物族·爬虫类族种族
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
