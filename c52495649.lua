--バラムニエル・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。把1张「新式魔厨」卡或者「食谱」卡从卡组加入手卡。
-- ②：以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽解放，从手卡·卡组把1只6星「新式魔厨」仪式怪兽特殊召唤。这张卡是已用「新式魔厨」怪兽的效果特殊召唤的场合，这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②两个效果，其中①为特殊召唤成功时发动的检索效果，②为起动效果并可于对方回合发动
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果①：这张卡特殊召唤成功的场合才能发动。把1张「新式魔厨」卡或者「食谱」卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽解放，从手卡·卡组把1只6星「新式魔厨」仪式怪兽特殊召唤。这张卡是已用「新式魔厨」怪兽的效果特殊召唤的场合，这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.spcon2)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e3)
end
-- 检索过滤器函数，用于筛选「新式魔厨」或「食谱」卡且能加入手牌的卡片
function s.thfilter(c)
	return c:IsSetCard(0x196,0x197) and c:IsAbleToHand()
end
-- 效果①的发动时处理函数，检查是否满足检索条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张符合条件的「新式魔厨」或「食谱」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组检索1张卡到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，提示选择并执行将卡加入手牌和确认卡片的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡从卡组加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②发动条件函数1，判断是否为非「新式魔厨」怪兽特殊召唤或未使用过「新式魔厨」怪兽的效果特殊召唤
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER==0 or not c:IsSpecialSummonSetCard(0x196)
end
-- 效果②发动条件函数2，判断是否为「新式魔厨」怪兽特殊召唤且已使用过「新式魔厨」怪兽的效果特殊召唤
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x196)
end
-- 解放过滤器函数，用于筛选可被效果解放的攻击表示怪兽
function s.relfilter(c)
	return c:IsReleasableByEffect() and c:IsAttackPos()
end
-- 特殊召唤过滤器函数，用于筛选6星「新式魔厨」仪式怪兽且能特殊召唤的卡片
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(6) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动时处理函数，检查是否满足解放和特殊召唤条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.relfilter(chkc) end
	-- 判断是否满足特殊召唤条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤条件：对方场上有至少1只可被解放的攻击表示怪兽
		and Duel.IsExistingTarget(s.relfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 判断是否满足特殊召唤条件：手卡或卡组中存在至少1张符合条件的6星「新式魔厨」仪式怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择对方场上的1只攻击表示怪兽作为对象
	local g=Duel.SelectTarget(tp,s.relfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为解放目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	-- 设置操作信息为从手卡或卡组特殊召唤1只6星「新式魔厨」仪式怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理函数，执行解放和特殊召唤的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且满足解放与召唤条件
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或卡组中选择1只符合条件的6星「新式魔厨」仪式怪兽
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if tc then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
