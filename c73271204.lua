--札再生
-- 效果：
-- ①：以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从手卡把1只「花札卫」怪兽无视召唤条件特殊召唤。
-- ②：这张卡被「花札卫」怪兽的效果送去墓地的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张魔法·陷阱卡加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
function c73271204.initial_effect(c)
	-- ①：以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入手卡。那之后，可以从手卡把1只「花札卫」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73271204,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73271204.target)
	e1:SetOperation(c73271204.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「花札卫」怪兽的效果送去墓地的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张魔法·陷阱卡加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73271204,1))  --"翻开卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c73271204.milcon)
	e2:SetTarget(c73271204.miltg)
	e2:SetOperation(c73271204.milop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以加入手卡的「花札卫」怪兽
function c73271204.filter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：确认墓地中是否存在符合条件的「花札卫」怪兽并选择其作为效果对象
function c73271204.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73271204.filter(chkc) end
	-- 检查自己墓地是否存在至少1只可以加入手卡的「花札卫」怪兽
	if chk==0 then return Duel.IsExistingTarget(c73271204.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「花札卫」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73271204.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤手卡中可以无视召唤条件特殊召唤的「花札卫」怪兽
function c73271204.spfilter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的效果处理：将对象怪兽加入手卡，并可以从手卡无视召唤条件特殊召唤1只「花札卫」怪兽
function c73271204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍符合效果，并成功将其加入手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取自己手卡中所有可以无视召唤条件特殊召唤的「花札卫」怪兽
		local tg=Duel.GetMatchingGroup(c73271204.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 检查手卡中是否存在符合条件的怪兽，且自己场上有可用的怪兽区域
		if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否选择从手卡特殊召唤1只「花札卫」怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(73271204,2)) then  --"是否把「花札卫」怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与加入手卡不视为同时进行（造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=tg:Select(tp,1,1,nil)
			-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 效果②的发动条件判定：检查这张卡是否因「花札卫」怪兽的效果被送去墓地
function c73271204.milcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(0xe6) and rc:IsType(TYPE_MONSTER)
end
-- 效果②的发动准备：确认自己卡组上方是否有至少5张卡
function c73271204.miltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡片数量是否在5张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤可以加入手卡的魔法·陷阱卡
function c73271204.milfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的效果处理：翻开卡组上方5张卡，可选择其中1张魔陷加入手卡，其余按喜欢顺序放回卡组上方
function c73271204.milop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己卡组的卡片数量不足5张则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	-- 确认自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()>0 then
		-- 禁用接下来的洗卡检测，防止因卡片加入手卡而自动洗牌
		Duel.DisableShuffleCheck()
		-- 检查翻开的卡中是否存在魔法·陷阱卡，并询问玩家是否将其中的1张加入手卡
		if g:IsExists(c73271204.milfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(73271204,3)) then  --"是否把魔法·陷阱卡加入手卡？"
			-- 提示玩家选择要加入手牌的魔法·陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c73271204.milfilter,1,1,nil)
			-- 将选择的魔法·陷阱卡加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切玩家的手卡
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		-- 让玩家将剩下的卡以喜欢的顺序放回卡组最上方
		Duel.SortDecktop(tp,tp,g:GetCount())
	end
end
