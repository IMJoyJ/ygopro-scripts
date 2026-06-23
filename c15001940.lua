--フォアグラシャ・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡回到持有者卡组。
-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只5·6星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别是①墓地的卡回到卡组和②解放怪兽特殊召唤仪式怪兽
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"墓地的卡回到卡组"
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
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
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
	-- 效果②的第二个触发条件为被选为攻击对象时，此时条件为始终成立
	e3:SetCondition(aux.TRUE)
	c:RegisterEffect(e3)
end
-- 效果①的发动时选择目标，选择1~3张墓地的卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 判断是否满足效果①的发动条件，即自己或对方墓地是否有可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1~3张墓地的卡作为效果①的目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置效果①的处理信息，将选中的卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果①的处理函数，将选中的卡返回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中与效果相关的卡
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将卡返回卡组并洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件，判断是否有怪兽成为攻击或效果的对象
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0
end
-- 筛选自己场上可解放的「新式魔厨」怪兽，且满足后续条件
function s.relfilter1(c,tp)
	return c:IsSetCard(0x196) and c:IsReleasableByEffect()
		-- 判断是否存在满足条件的第二只怪兽用于解放
		and Duel.IsExistingMatchingCard(s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
end
-- 筛选满足解放条件的攻击表示怪兽
function s.relfilter2(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 判断解放的两只怪兽是否能提供足够的怪兽区
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- 筛选满足条件的5或6星「新式魔厨」仪式怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(5,6) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动时判断条件，判断是否有满足条件的解放对象和仪式怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有满足条件的解放对象
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 判断是否有满足条件的仪式怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果②的处理信息，准备特殊召唤仪式怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理函数，选择解放对象并特殊召唤仪式怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择一只自己场上的「新式魔厨」怪兽用于解放
	local g=Duel.SelectMatchingCard(tp,s.relfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g:GetFirst()
	if not tc1 then return end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择一只对方场上的攻击表示怪兽用于解放
	local tc2=Duel.SelectMatchingCard(tp,s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc1,tp,tc1):GetFirst()
	g:AddCard(tc2)
	-- 判断是否成功解放两只怪兽
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只5或6星的「新式魔厨」仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的仪式怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
