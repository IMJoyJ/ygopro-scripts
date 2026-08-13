--巳剣之神鏡
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的爬虫类族怪兽解放，从自己的手卡·墓地把1只爬虫类族仪式怪兽仪式召唤。
-- ②：这张卡在墓地存在的状态，自己场上的「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的其中任意种被解放的场合才能发动。这张卡回到卡组。
local s,id,o=GetID()
-- 卡片效果注册入口：先登记卡名关联，然后创建①仪式召唤效果（限定1回合1次）和②墓地回卡组效果（限定1回合1次）。
function s.initial_effect(c)
	-- 将「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的卡号记录到该卡的卡名列表中，用于关联这些卡名。
	aux.AddCodeList(c,13332685,19899073,55397172)
	-- 调用仪式召唤辅助函数添加①效果：从手卡·墓地仪式召唤1只爬虫类族仪式怪兽，解放的素材必须为爬虫类族怪兽，且暂不注册以便继续设置次数限制。
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
-- 仪式召唤的怪兽过滤条件：选择爬虫类族怪兽。
function s.spfilter(c)
	return c:IsRace(RACE_REPTILE)
end
-- 仪式召唤解放素材的过滤条件：只允许解放爬虫类族怪兽。
function s.mfilter(c)
	return c:IsRace(RACE_REPTILE)
end
-- 判定被解放的怪兽是否满足②条件：必须是从场上被解放、之前控制者为我方、且解放前在场上的卡号属于三张巳剑之一。
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and (c:GetPreviousCodeOnField()==13332685 or c:GetPreviousCodeOnField()==19899073 or c:GetPreviousCodeOnField()==55397172)
end
-- ②效果的发动条件：本次解放的怪兽中存在符合条件的巳剑，且解放集合中不包含这张巳剑之神镜自身。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果发动时检查这张卡能否回卡组，并做好目标合法性判定。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置效果处理信息：将要送回卡组的卡为这张巳剑之神镜自身，数量为1，回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：取得这张卡，若其仍与连锁相关且不受王家长眠之谷等禁止墓地效果的影响，则将其送回卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与当前连锁保持联系（没有被中途除外等），且通过王家长眠之谷的过滤器检查，确保墓地效果可用。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张巳剑之神镜以效果原因送回持有者卡组，并标记需要洗牌。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
