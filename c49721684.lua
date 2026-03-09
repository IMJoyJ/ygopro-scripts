--巳剣之神鏡
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的爬虫类族怪兽解放，从自己的手卡·墓地把1只爬虫类族仪式怪兽仪式召唤。
-- ②：这张卡在墓地存在的状态，自己场上的「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的其中任意种被解放的场合才能发动。这张卡回到卡组。
local s,id,o=GetID()
-- 注册卡片效果，包括仪式召唤和回到卡组的效果
function s.initial_effect(c)
	-- 记录该卡与「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的关联
	aux.AddCodeList(c,13332685,19899073,55397172)
	-- 设置仪式召唤条件：解放手牌或场上的爬虫类族怪兽，从手牌或墓地仪式召唤爬虫类族仪式怪兽
	local e1=aux.AddRitualProcGreater2(c,s.spfilter,LOCATION_HAND+LOCATION_GRAVE,nil,s.mfilter,true)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的其中任意种被解放的场合才能发动。这张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 筛选手牌或场上的爬虫类族怪兽作为仪式召唤的祭品
function s.spfilter(c)
	return c:IsRace(RACE_REPTILE)
end
-- 筛选墓地中的爬虫类族怪兽作为仪式召唤的祭品
function s.mfilter(c)
	return c:IsRace(RACE_REPTILE)
end
-- 判断被解放的怪兽是否为「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」之一
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and (c:GetPreviousCodeOnField()==13332685 or c:GetPreviousCodeOnField()==19899073 or c:GetPreviousCodeOnField()==55397172)
end
-- 判断是否有符合条件的怪兽被解放且不是自身
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置发动时的操作信息，确定将自身送回卡组
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息为将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将自身送回卡组的操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否仍在连锁中且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身送回卡组并洗牌
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
