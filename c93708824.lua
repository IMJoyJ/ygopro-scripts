--ロクスローズ・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把「十六夜蔷薇龙」以外的有「黑蔷薇龙」的卡名记述的1张卡从卡组加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「蔷薇龙」怪兽或植物族同调怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡加入手卡。
function c93708824.initial_effect(c)
	-- 注册卡片效果中记述了「黑蔷薇龙」（卡号73580471）的事实
	aux.AddCodeList(c,73580471)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。把「十六夜蔷薇龙」以外的有「黑蔷薇龙」的卡名记述的1张卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93708824,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,93708824)
	e1:SetTarget(c93708824.srtg)
	e1:SetOperation(c93708824.srop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「蔷薇龙」怪兽或植物族同调怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93708824,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,93708825)
	e3:SetCondition(c93708824.thcon)
	e3:SetTarget(c93708824.thtg)
	e3:SetOperation(c93708824.thop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「十六夜蔷薇龙」以外的有「黑蔷薇龙」卡名记述且能加入手卡的卡的过滤函数
function c93708824.srfilter(c)
	-- 检查卡片是否记述了「黑蔷薇龙」卡名，且卡名不等于「十六夜蔷薇龙」，且可以加入手卡
	return aux.IsCodeListed(c,73580471) and not c:IsCode(93708824) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测函数
function c93708824.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93708824.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数
function c93708824.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c93708824.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示被战斗或对方效果破坏的「蔷薇龙」怪兽或植物族同调怪兽的过滤函数
function c93708824.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsPreviousSetCard(0x1123) or c:GetPreviousRaceOnField()&RACE_PLANT~=0 and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果②的发动条件函数，检查被破坏的卡中是否包含满足条件的怪兽，且不包含自身
function c93708824.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c93708824.cfilter,1,nil,tp)
end
-- 效果②的发动准备与合法性检测函数
function c93708824.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理的操作信息，表示该效果会将墓地的这张卡（自身）加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数
function c93708824.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡（自身）因效果加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
