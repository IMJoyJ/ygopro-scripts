--ブエリヤベース・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「新式魔厨」卡加入手卡。剩余回到卡组。
-- ②：场上的这张卡成为攻击·效果的对象时才能发动。这张卡和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只2·3星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置①②两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「新式魔厨」卡加入手卡。剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"翻开卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡成为攻击·效果的对象时才能发动。这张卡和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只2·3星的「新式魔厨」仪式怪兽特殊召唤。
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
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判断函数，检查是否满足发动条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否至少有5张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	-- 设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
end
-- ①效果中用于筛选「新式魔厨」卡的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x196) and c:IsAbleToHand()
end
-- ①效果的处理函数，翻开卡组并选择加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 翻开玩家卡组最上方的5张卡
	Duel.ConfirmDecktop(p,5)
	-- 获取翻开的5张卡组成的卡片组
	local g=Duel.GetDecktopGroup(p,5)
	local tg=g:Filter(s.thfilter,nil)
	-- 判断是否有符合条件的「新式魔厨」卡并询问是否选择
	if #tg>0 and Duel.SelectYesNo(p,aux.Stringid(id,2)) then  --"是否选卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=tg:Select(p,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-p,sg)
	end
	-- 将翻开的卡重新洗回卡组
	Duel.ShuffleDeck(p)
end
-- ②效果的发动条件判断函数，检查是否成为攻击或效果对象
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 用于筛选可解放的攻击表示怪兽的过滤函数
function s.relfilter(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 检查解放怪兽后是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- 用于筛选2·3星「新式魔厨」仪式怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(2,3) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动条件判断函数，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect()
		-- 检查场上是否存在可解放的攻击表示怪兽
		and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
		-- 检查手卡或卡组中是否存在符合条件的2·3星「新式魔厨」仪式怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，确定要特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的处理函数，解放怪兽并特殊召唤仪式怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择符合条件的攻击表示怪兽进行解放
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp,c)
	if g:GetCount()==0 then return end
	g:AddCard(c)
	-- 执行解放操作并判断是否成功解放2只怪兽
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的2·3星「新式魔厨」仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的仪式怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
