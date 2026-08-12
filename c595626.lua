--アンクリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时把这张卡从手卡丢弃，以这张卡以外的自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段送去墓地。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地选1张「死者苏生」加入手卡。
function c595626.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时把这张卡从手卡丢弃，以这张卡以外的自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(595626,0))  --"将怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,595626)
	e1:SetCondition(c595626.spcon)
	e1:SetCost(c595626.spcost)
	e1:SetTarget(c595626.sptg)
	e1:SetOperation(c595626.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地选1张「死者苏生」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(595626,1))  --"检索「死者苏生」"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,595627)
	e2:SetCondition(c595626.thcon)
	e2:SetOperation(c595626.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方回合（对方怪兽攻击宣言时）
function c595626.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 效果①的发动代价：把手牌的这张卡丢弃
function c595626.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤墓地中可以特殊召唤的怪兽
function c595626.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空格、选择墓地中除这张卡以外的1只怪兽作为对象）
function c595626.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c595626.spfilter(chkc,e,tp) and chkc~=c end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在除这张卡以外、可以特殊召唤的怪兽作为对象
		and Duel.IsExistingTarget(c595626.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c595626.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,c,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤对象怪兽，并注册结束阶段送去墓地的效果）
function c595626.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(595626,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段送去墓地。这个回合的结束阶段，从自己的卡组·墓地选1张「死者苏生」加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c595626.tgcon)
		e1:SetOperation(c595626.tgop)
		-- 注册在结束阶段将特殊召唤的怪兽送去墓地的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍在场上且标记未失效，若失效则重置该效果
function c595626.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(595626)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段将特殊召唤的怪兽送去墓地的具体操作
function c595626.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该怪兽送去墓地
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
-- 效果②的发动条件：这张卡被战斗或效果破坏送去墓地
function c595626.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤卡组或墓地中的「死者苏生」
function c595626.thfilter(c)
	return c:IsCode(83764718) and c:IsAbleToHand()
end
-- 效果②的效果处理：注册一个在当前回合结束阶段发动的效果，用于检索「死者苏生」
function c595626.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己的卡组·墓地选1张「死者苏生」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetCondition(c595626.thcon2)
	e1:SetOperation(c595626.thop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段检索「死者苏生」的效果
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段检索效果的发动条件：卡组或墓地存在「死者苏生」
function c595626.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的卡组或墓地是否存在至少1张「死者苏生」
	return Duel.IsExistingMatchingCard(c595626.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段检索效果的具体操作（从卡组或墓地选择1张「死者苏生」加入手牌）
function c595626.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张不受「王家长眠之谷」影响的「死者苏生」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c595626.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
