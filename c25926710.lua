--古尖兵ケルベク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组有卡被送去对方墓地的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽回到持有者手卡。
-- ②：这张卡从手卡·卡组送去墓地的场合才能发动。从双方卡组上面把5张卡送去墓地。那之后，自己墓地有「现世与冥界的逆转」存在的场合，可以从自己墓地选1张陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个触发效果
function s.initial_effect(c)
	-- 记录该卡与「现世与冥界的逆转」的关联
	aux.AddCodeList(c,17484499)
	-- ①：从手卡·卡组有卡被送去对方墓地的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组送去墓地的场合才能发动。从双方卡组上面把5张卡送去墓地。那之后，自己墓地有「现世与冥界的逆转」存在的场合，可以从自己墓地选1张陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡片来自对方卡组或手牌并被送去墓地
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and c:IsControler(1-tp)
end
-- 判断是否满足①效果的触发条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：特殊召唤的怪兽且能送回手牌
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- 设置①效果的发动条件和目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	local c=e:GetHandler()
	-- 检查是否有满足条件的对方场上的特殊召唤怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查手卡是否能特殊召唤且场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置效果处理信息：送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行①效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查手卡是否能特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取当前效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsAbleToHand() then
			-- 中断当前连锁效果处理
			Duel.BreakEffect()
			-- 将目标怪兽送回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 判断②效果是否满足触发条件
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- 设置②效果的发动条件和处理信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方是否都能从卡组顶部送去5张卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	-- 设置效果处理信息：从双方卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,5)
end
-- 过滤条件：可盖放的陷阱卡
function s.sfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 执行②效果的处理流程
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方卡组顶部5张卡
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方卡组顶部5张卡
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁止卡组洗切检测
	Duel.DisableShuffleCheck()
	-- 将双方卡组顶部的卡送去墓地
	if Duel.SendtoGrave(g1,REASON_EFFECT)~=0 and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 检查己方墓地是否存在「现世与冥界的逆转」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) then
		-- 获取满足条件的可盖放陷阱卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE,0,nil)
		-- 询问玩家是否选择陷阱卡盖放
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从墓地选1张陷阱卡盖放？"
			-- 中断当前连锁效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的陷阱卡盖放
			Duel.SSet(tp,sg)
		end
	end
end
