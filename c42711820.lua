--スクラップ・ウォリアー
-- 效果：
-- 「废铁同调士」＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组选1只「废品同调士」或者1张有「废品战士」的卡名记述的卡加入手卡或送去墓地。
-- ②：「废铁战士」以外的自己场上的以下怪兽发动的效果不会被无效化。
-- ●有「废品战士」的卡名记述的怪兽
-- ●原本卡名包含「战士」的同调怪兽
local s,id,o=GetID()
-- 初始化效果函数，注册同调召唤手续、检索效果和无效化效果
function s.initial_effect(c)
	-- 为卡片注册“记载着废品战士”和“废品同调士”的卡名
	aux.AddCodeList(c,60800381,63977008)
	-- 为卡片添加同调召唤素材代码列表，允许使用废铁同调士作为素材
	aux.AddMaterialCodeList(c,16449363)
	-- 添加同调召唤手续，要求1只废铁同调士或具有特定效果的调整以外的怪兽
	aux.AddSynchroProcedure(c,s.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组选1只「废品同调士」或者1张有「废品战士」的卡名记述的卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：「废铁战士」以外的自己场上的以下怪兽发动的效果不会被无效化。●有「废品战士」的卡名记述的怪兽●原本卡名包含「战士」的同调怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.effectfilter)
	c:RegisterEffect(e2)
end
s.material_setcode=0x1017
-- 同调召唤时用于过滤素材的函数，判断是否为废铁同调士或具有特定效果的怪兽
function s.tfilter(c)
	return c:IsCode(16449363) or c:IsHasEffect(20932152)
end
-- 检索效果的发动条件，判断是否为同调召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索卡组中满足条件的卡片过滤函数，包括废品同调士或记载有废品战士的卡
function s.thfilter(c)
	-- 判断卡片是否为废品同调士或记载有废品战士的卡，并且可以加入手卡或送去墓地
	return (c:IsCode(63977008) or aux.IsCodeListed(c,60800381)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 检索效果的目标选择函数，检查卡组中是否存在满足条件的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 检索效果的处理函数，选择卡片并决定将其加入手卡或送去墓地
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断是否可以将卡片加入手卡，若不能则选择送去墓地
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 将卡片送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 无效化效果的过滤函数，判断是否为特定怪兽发动的效果
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取当前连锁的信息，包括触发效果、玩家和位置
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and not tc:IsCode(id) and loc==LOCATION_MZONE and te:IsActiveType(TYPE_MONSTER)
		-- 判断触发效果是否为具有特定代码或原本种族为战士的同调怪兽
		and (tc:IsOriginalSetCard(0x66) and tc:IsType(TYPE_SYNCHRO) or aux.IsCodeListed(tc,60800381))
end
