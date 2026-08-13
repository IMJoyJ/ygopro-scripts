--古尖兵ケルベク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组有卡被送去对方墓地的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽回到持有者手卡。
-- ②：这张卡从手卡·卡组送去墓地的场合才能发动。从双方卡组上面把5张卡送去墓地。那之后，自己墓地有「现世与冥界的逆转」存在的场合，可以从自己墓地选1张陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册古尖兵的两个效果：①在对方控制的卡从手卡·卡组送入对方墓地时，可特召自身并选择对方场上1只特殊召唤怪兽弹回手牌；②此卡从手卡·卡组送墓时，双方各从卡组顶把5张卡送墓，若自己墓地有「现世与冥界的逆转」还可盖1张陷阱。
function s.initial_effect(c)
	-- 将「现世与冥界的逆转」（17484499）登记为这张卡记述的卡名，供规则中涉及“记载有卡名的卡”的判断使用。
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
-- 过滤条件：卡在送去墓地前位于手卡或卡组，且其控制者是对方（1-tp），用于判断“从手卡·卡组有卡被送去对方墓地”。
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and c:IsControler(1-tp)
end
-- ①的发动条件：本次送入墓地的卡中存在满足上述过滤条件的卡（即对方控制的卡从手卡·卡组被送入对方墓地）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①的对象过滤：对方场上的特殊召唤怪兽，且可以被加入手卡。
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- ①的目标处理函数：验证对象卡是否合法（chkc分支），并在发动时检查存在可选对象、自己场上有空位、此卡可被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	local c=e:GetHandler()
	-- 发动时检查：是否存在至少1只对方场上的特殊召唤怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 发动时检查：自己场上是否有可用的怪兽区域，以及手牌的这张卡能否被特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 弹出选择提示，让玩家选择要返回手牌的对象怪兽（写入选择消息缓存）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1只符合条件的特殊召唤怪兽，并将其设置为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果预定包含特殊召唤这张卡（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：本次效果预定包含将对象怪兽返回手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：先将此卡从手卡特殊召唤；若特殊召唤成功，则确认对象仍与效果关联且能回手后，通过BreakEffect将回手作为后续处理，把对象怪兽送回持有者手卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与效果关联（例如没有离场/失效），并且特殊召唤成功（返回数>0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 取得效果发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsAbleToHand() then
			-- 中断当前效果处理，使后续“对象回手”不再与特殊召唤同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 以效果原因将对象怪兽送回其持有者手卡（nil表示回到持有者手卡）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- ②的发动条件：此卡自身从手卡或卡组被送入墓地。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- ②的目标处理：确认双方都能从卡组顶送5张卡去墓地，并设置操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：双方玩家卡组是否都至少有5张卡可以送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	-- 设置操作信息：预定将双方玩家卡组顶各5张送去墓地（PLAYER_ALL表示双方，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,5)
end
-- 过滤函数：陷阱卡且可以被盖放。
function s.sfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果处理：取双方卡组顶各5张合并送入墓地；若这些卡实际被送入墓地且自己墓地有「现世与冥界的逆转」，则询问玩家是否从墓地选1张陷阱盖放，并执行盖放。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组最上方5张卡。
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 取得对方卡组最上方5张卡。
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁止系统在本次操作后自动检测并洗切卡组（因为是从卡组顶直接取卡处理）。
	Duel.DisableShuffleCheck()
	-- 将合并后的10张卡以效果原因送入墓地；若实际送墓数不为0，且其中有卡确实在墓地，则进入后续检查。
	if Duel.SendtoGrave(g1,REASON_EFFECT)~=0 and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 检查自己墓地是否有「现世与冥界的逆转」（卡号17484499），作为是否允许盖放陷阱卡的条件。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) then
		-- 获取自己墓地中能够盖放且不受「王家长眠之谷」效果影响的陷阱卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若存在可选的陷阱卡，则询问玩家是否选择1张盖放；选择“是”才继续执行。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从墓地选1张陷阱卡盖放？"
			-- 中断效果处理，使随后的盖放操作视为另一次处理，避免错过时点。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡片（写入选择消息缓存HINTMSG_SET）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选中的陷阱卡以里侧表示盖放到自己场上（Duel.SSet默认里侧表示）。
			Duel.SSet(tp,sg)
		end
	end
end
