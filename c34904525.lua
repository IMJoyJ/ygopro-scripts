--雷風魔神－ゲート・ガーディアン
-- 效果：
-- 「雷魔神-桑迦」＋「风魔神-修迦」
-- 把自己场上的上记的卡除外的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。把有「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的卡名全部记述的1张魔法·陷阱卡从卡组加入手卡。
-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「雷魔神-桑迦」或「风魔神-修迦」特殊召唤。
function c34904525.initial_effect(c)
	c:EnableReviveLimit()
	-- 将「水魔神-斯迦」(98434877)登记为这张卡效果文中记载的卡名，供后续检索同时记述三魔神卡名的魔法·陷阱卡时判断使用。
	aux.AddCodeList(c,98434877)
	-- 为这张卡注册融合召唤手续，融合素材为「雷魔神-桑迦」＋「风魔神-修迦」（可适用代用素材/融解处理），实现通过融合召唤方式出场。
	aux.AddFusionProcCode2(c,25955164,62340868,true,true)
	-- 注册接触融合特殊召唤手续：不发动融合魔法，而是把自己场上能够作为代价除外的上述融合素材怪兽除外（正面表示除外，除外作为COST），从额外卡组特殊召唤这张卡，对应“把自己场上的上记的卡除外的场合才能特殊召唤”。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。（注册不可无效、不可复制的特殊召唤条件，限制这张卡只能通过上述手续特殊召唤）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。把有「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的卡名全部记述的1张魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34904525,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,34904525)
	e1:SetTarget(c34904525.thtg)
	e1:SetOperation(c34904525.thop)
	c:RegisterEffect(e1)
	-- ②：特殊召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。自己的除外状态的1只「雷魔神-桑迦」或「风魔神-修迦」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34904525,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c34904525.spcon)
	e2:SetTarget(c34904525.sptg)
	e2:SetOperation(c34904525.spop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤条件：对象必须是魔法·陷阱卡且能够加入手卡，并且其效果文本中同时记述了「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」三个卡名。
function c34904525.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		-- 追加判定该魔法·陷阱卡的效果文本中是否同时记载着「雷魔神-桑迦」(25955164)、「风魔神-修迦」(62340868)和「水魔神-斯迦」(98434877)这三个卡名。
		and aux.IsCodeListed(c,25955164) and aux.IsCodeListed(c,62340868) and aux.IsCodeListed(c,98434877)
end
-- ①效果的发动条件与操作信息设置：当chk==0时检查卡组中是否存在满足检索条件的魔法·陷阱卡；若存在，则将本次操作信息设置为从卡组将1张卡加入手卡。
function c34904525.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性判定阶段，确认己方卡组中至少存在1张满足thfilter过滤条件的魔法·陷阱卡，以保证效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34904525.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：该效果处理时会将1张卡从卡组加入手牌（类别为TOHAND/SEARCH），目标位置为卡组，供系统进行后续连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果实际处理：先从卡组选择1张符合条件的魔法·陷阱卡加入手牌，再向对手展示那张卡。
function c34904525.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示，将选择提示消息缓存给玩家tp，用于接下来的卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由己方玩家从卡组中筛选并选择1张满足thfilter条件的魔法·陷阱卡（不取对象，效果处理时选择）作为加入手牌的目标。
	local tg=Duel.SelectMatchingCard(tp,c34904525.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功选出了目标卡且将该卡以效果原因送入手牌成功，则继续执行后续的确认展示处理。
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 then
		-- 把检索加入手牌的那张卡展示给对手玩家确认（公开检索信息）。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- ②效果的发动条件：这张卡是以特殊召唤方式出场过的表侧表示怪兽，因对方的原因从己方怪兽区域离场，且离场前是表侧表示、原本控制者是自己。
function c34904525.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 定义②效果可选的特殊召唤对象：除外状态中的「雷魔神-桑迦」或「风魔神-修迦」，且处于表侧表示（公开的除外状态）并能被正常特殊召唤。
function c34904525.spfilter(c,e,tp)
	return c:IsCode(25955164,62340868) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与操作信息设置：检查己方怪兽区有空位且除外区存在符合条件的「雷魔神-桑迦」或「风魔神-修迦」；满足后设置从除外区特殊召唤1只怪兽的操作信息。
function c34904525.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定时首先确认己方主要怪兽区有可用的空格，以保证后续特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认除外区存在至少1只满足spfilter过滤条件、可以被效果特殊召唤的「雷魔神-桑迦」或「风魔神-修迦」，从而允许发动②效果。
		and Duel.IsExistingMatchingCard(c34904525.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将从除外区特殊召唤1只怪兽，特殊召唤类别为SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- ②效果实际处理：在怪兽区仍有空位的前提下，从除外区选择1只符合条件的「雷魔神-桑迦」或「风魔神-修迦」，以表侧表示特殊召唤到自己场上。
function c34904525.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方主要怪兽区仍有空位；若没有空位则直接结束本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，将选择提示消息缓存给玩家tp。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由己方玩家从除外区选择1只满足spfilter条件且能够被当前效果特殊召唤的「雷魔神-桑迦」或「风魔神-修迦」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c34904525.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择出的怪兽特殊召唤到己方场上，以表侧表示出场。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
