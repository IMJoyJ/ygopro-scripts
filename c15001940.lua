--フォアグラシャ・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡回到持有者卡组。
-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只5·6星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别是①效果（特殊召唤成功时将墓地卡送回卡组）和②效果（成为攻击对象时解放怪兽并特殊召唤仪式怪兽）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只5·6星的「新式魔厨」仪式怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	-- 效果②的触发条件为成为攻击对象时，此处设置为始终满足条件
	e3:SetCondition(aux.TRUE)
	c:RegisterEffect(e3)
end
-- ①效果的发动时点处理函数，用于选择目标墓地卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 检查是否满足①效果发动条件，即自己或对方墓地是否有可送回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择1~3张可送回卡组的墓地卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置操作信息，告知连锁将要处理的卡组数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ①效果的处理函数，将选中的卡送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中与效果相关的卡组
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将卡组中的卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数，判断是否有怪兽进入攻击对象状态
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0
end
-- 筛选自己场上可解放的「新式魔厨」怪兽，且满足后续条件
function s.relfilter1(c,tp)
	return c:IsSetCard(0x196) and c:IsReleasableByEffect()
		-- 检查是否存在满足条件的第二只怪兽用于解放
		and Duel.IsExistingMatchingCard(s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
end
-- 筛选自己或对方场上可解放的攻击表示怪兽
function s.relfilter2(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 检查解放这两只怪兽后是否还有可用的怪兽区
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- 筛选5或6星的「新式魔厨」仪式怪兽，用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(5,6) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动时点处理函数，用于判断是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有满足条件的怪兽可解放
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查手牌或卡组中是否有满足条件的仪式怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，告知连锁将要处理的特殊召唤怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的处理函数，执行解放和特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 选择一只可解放的「新式魔厨」怪兽
	local g=Duel.SelectMatchingCard(tp,s.relfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g:GetFirst()
	if not tc1 then return end
	-- 提示玩家选择第二只要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 选择一只可解放的攻击表示怪兽
	local tc2=Duel.SelectMatchingCard(tp,s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc1,tp,tc1):GetFirst()
	g:AddCard(tc2)
	-- 执行解放操作，确保成功解放两只怪兽
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌或卡组中选择一只满足条件的仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的仪式怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
