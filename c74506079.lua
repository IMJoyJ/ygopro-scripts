--ワーム・ゼロ
-- 效果：
-- 名字带有「异虫」的爬虫类族怪兽×2只以上
-- 这张卡的攻击力变成作为融合素材的怪兽种类×500的数值。这张卡得到作为融合素材的怪兽种类的以下效果。
-- ●2种类以上：1回合1次，可以把自己墓地1只爬虫类族怪兽里侧守备表示特殊召唤。
-- ●4种类以上：可以把自己墓地1只爬虫类族怪兽从游戏中除外，场上1只怪兽送去墓地。
-- ●6种类以上：1回合1次，从自己卡组抽1张卡。
function c74506079.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只以上（最多127只）满足过滤条件的怪兽作为素材。
	aux.AddFusionProcFunRep2(c,c74506079.ffilter,2,127,true)
	-- 这张卡的攻击力变成作为融合素材的怪兽种类×500的数值。这张卡得到作为融合素材的怪兽种类的以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c74506079.matcheck)
	c:RegisterEffect(e2)
end
-- 过滤融合素材：名字带有「异虫」的爬虫类族怪兽。
function c74506079.ffilter(c,fc)
	return c:IsFusionSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
-- 融合素材检查函数，根据作为融合素材的怪兽种类数量，赋予这张卡对应的攻击力数值和效果。
function c74506079.matcheck(e,c)
	local ct=c:GetMaterial():GetClassCount(Card.GetCode)
	if ct>0 then
		-- 这张卡的攻击力变成作为融合素材的怪兽种类×500的数值。
		local ae=Effect.CreateEffect(c)
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetCode(EFFECT_SET_ATTACK)
		ae:SetValue(ct*500)
		ae:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
		c:RegisterEffect(ae)
	end
	if ct>=2 then
		-- ●2种类以上：1回合1次，可以把自己墓地1只爬虫类族怪兽里侧守备表示特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(74506079,0))  --"墓地1只爬虫类族特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetTarget(c74506079.sptg)
		e1:SetOperation(c74506079.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
	if ct>=4 then
		-- ●4种类以上：可以把自己墓地1只爬虫类族怪兽从游戏中除外，场上1只怪兽送去墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(74506079,1))  --"场上1只怪兽送去墓地"
		e1:SetCategory(CATEGORY_TOGRAVE)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCost(c74506079.tgcost)
		e1:SetTarget(c74506079.tgtg)
		e1:SetOperation(c74506079.tgop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
	if ct>=6 then
		-- ●6种类以上：1回合1次，从自己卡组抽1张卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(74506079,2))  --"抽1张卡"
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetTarget(c74506079.drtg)
		e1:SetOperation(c74506079.drop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己墓地中可以里侧守备表示特殊召唤的爬虫类族怪兽。
function c74506079.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 2种类以上效果的发动准备与目标选择（检查怪兽区域空格、墓地是否存在符合条件的怪兽，并选择目标）。
function c74506079.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c74506079.spfilter(chkc,e,tp) end
	-- 检查发动时自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的爬虫类族怪兽。
		and Duel.IsExistingTarget(c74506079.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的爬虫类族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c74506079.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含将选中的1张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 2种类以上效果的实际处理（将选中的墓地怪兽里侧守备表示特殊召唤，并给对方确认）。
function c74506079.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_REPTILE) then
		-- 将目标怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认被里侧特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤自己墓地中可以作为cost除外的爬虫类族怪兽。
function c74506079.costfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
-- 4种类以上效果的cost处理（检查并除外自己墓地1只爬虫类族怪兽）。
function c74506079.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以作为cost除外的爬虫类族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c74506079.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的爬虫类族怪兽。
	local rg=Duel.SelectMatchingCard(tp,c74506079.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动的cost。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 4种类以上效果的发动准备与目标选择（选择场上1只怪兽作为送去墓地的对象）。
function c74506079.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明此效果包含将选中的1张卡送去墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 4种类以上效果的实际处理（将选中的场上怪兽送去墓地）。
function c74506079.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的送去墓地的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 6种类以上效果的发动准备（检查是否能抽卡，并设置抽卡玩家和张数）。
function c74506079.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽卡张数）。
	Duel.SetTargetParam(1)
	-- 设置连锁信息，表明此效果包含让玩家抽1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 6种类以上效果的实际处理（执行抽卡）。
function c74506079.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时设置的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
