--蕾禍ノ鎖蛇巳
-- 效果：
-- 包含昆虫族·植物族·爬虫类族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽的效果发动的场合才能发动。这个回合，双方不能把手卡的怪兽的效果发动。
-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①效果和②效果
function s.initial_effect(c)
	-- 设定连接召唤手续：需要2只以上的怪兽，且必须包含昆虫族·植物族·爬虫类族怪兽
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：对方把怪兽的效果发动的场合才能发动。这个回合，双方不能把手卡的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"封锁效果"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.accon)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤自身"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接素材检查：用于确认连接素材中是否包含至少1只昆虫族、植物族或爬虫类族怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
-- ①效果的发动条件：对方发动了怪兽的效果
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果的处理：在场上注册一个持续到回合结束的全局效果，使双方玩家不能发动手中怪兽的效果
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 以自己场上1只昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽回到卡组最下面，这张卡特殊召唤。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的条件：发动的地点在手卡，且是怪兽卡的效果
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件：自己场上表侧表示的昆虫族、植物族或爬虫类族怪兽，且该怪兽离开场后能空出怪兽区域，并且能回到卡组
function s.tdfilter(c,tp)
	-- 检查卡片是否为表侧表示、属于昆虫族/植物族/爬虫类族、能空出怪兽区域且能回到卡组
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToDeck()
end
-- ②效果的发动准备：检查是否能选择符合条件的怪兽作为对象，以及墓地的这张卡是否能特殊召唤，并进行取对象和宣告操作
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tdfilter(chkc,tp) end
	-- 效果发动时的可行性检查：是否存在可作为对象的怪兽，且自身是否能特殊召唤
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：将选中的对象怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息：将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理：将作为对象的怪兽回到卡组最下面，若成功则将这张卡特殊召唤，并适用特殊召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用此效果，若是怪兽则将其送回卡组最下面，并确认是否成功回到卡组或额外卡组
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 检查自己场上是否有空余的怪兽区域，且墓地的这张卡是否仍适用此效果
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：不能特殊召唤昆虫族·植物族·爬虫类族以外的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
