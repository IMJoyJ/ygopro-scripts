--千年の十字
-- 效果：
-- ①：选自己的手卡·卡组·场上（表侧表示）5张「被封印」怪兽卡，给双方确认。那之后，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤。除「千年」怪兽卡、原本等级是10星以上的「艾克佐迪亚」怪兽卡外的表侧表示的怪兽卡在自己场上存在的场合，再让那些全部回到卡组。这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
local s,id,o=GetID()
-- 注册卡片效果核心的特召「幻之召唤神 艾克佐迪亚」、清理场上非特定怪兽、自身离场洗回卡组、以及整回合召唤限制的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「幻之召唤神 艾克佐迪亚」（卡片密码：83257450）
	aux.AddCodeList(c,83257450)
	-- ①：选自己的手卡·卡组·场上（表侧表示）5张「被封印」怪兽卡，给双方确认。那之后，从额外卡组把1只「幻之召唤神 艾克佐迪亚」特殊召唤。除了「千年」怪兽卡、原本等级是10星以上的「艾克佐迪亚」怪兽卡外的表侧表示的怪兽卡在自己场上存在的场合，再让那些全部回到卡组。这个回合，自己不能把怪兽召唤·反转召唤·特殊召唤。发动后这张卡不送去墓地，回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 在效果的 Cost 中设定 Label 以标记这是发动的本步骤以避开非法触发
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 手卡、卡组、场上的「被封印」怪兽卡片的过滤条件
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x40) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 额外卡组中可特殊召唤的「幻之召唤神 艾克佐迪亚」的过滤与区域判断条件
function s.spfilter(c,e,tp)
	return c:IsCode(83257450)
		-- 检查自己额外卡组是否存在「幻之召唤神 艾克佐迪亚」且额外区域有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 魔法卡发动时的可行性检查（是否已被限制发动或缺少素材）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查是否存在某些禁止此卡发动或限制特召的玩家封锁效果
		return not Duel.IsPlayerAffectedByEffect(tp,4130270)
			-- 检查手卡/卡组/场上是否共有5张可供展示的「被封印」怪兽卡
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,nil)
			-- 检查额外卡组是否拥有可以进行特殊召唤的「幻之召唤神 艾克佐迪亚」
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	-- 设置操作信息为从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 场上需要洗回卡组的除「千年」或10星以上「艾克佐迪亚」外的表侧表示怪兽卡片
function s.dfilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and not (c:GetOriginalLevel()>=10 and c:IsSetCard(0xde) or c:IsSetCard(0x1ae))
end
-- 场上符合清理条件且能够返回卡组的表侧表示怪兽
function s.tdfilter(c)
	return s.dfilter(c) and c:IsAbleToDeck()
end
-- 场上符合清理条件但由于免疫等效果无法返回卡组 the 表侧表示怪兽
function s.ndfilter(c)
	return s.dfilter(c) and not c:IsAbleToDeck()
end
-- 特召「幻之召唤神 艾克佐迪亚」与清理场上非特定怪兽效果的执行、以及本回合全部召唤行为封锁的誓约效果注册
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认手卡/卡组/场上是否存在5张可以公开的「被封印」怪兽卡
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,nil) then
		-- 向玩家提示选择需要公开的5张被封印卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手卡、卡组、场上选择5张「被封印」怪兽卡
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,5,5,nil,e,tp)
		-- 由自己确认选中的这5张被封印的卡片
		Duel.ConfirmCards(tp,g)
		-- 向对方玩家公开确认这5张被封印的卡片
		Duel.ConfirmCards(1-tp,g)
		if g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>=1 then
			-- 若公开的卡中有手牌中的卡片，则将手牌重新洗牌
			Duel.ShuffleHand(tp)
		end
		-- 向玩家提示选择从额外卡组召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择「幻之召唤神 艾克佐迪亚」
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		-- 若「幻之召唤神 艾克佐迪亚」成功特殊召唤，则继续处理后续的场上清理
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 获取自己场上所有符合清理洗回卡组条件的表侧表示怪兽
			local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,0,nil)
			if #tg>0 then
				-- 在特召成功后且场上有需要清理的怪兽时，切断连锁以执行后续动作
				Duel.BreakEffect()
				-- 将所有需要清理的怪兽洗回持有者的卡组
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
	-- 注册限制玩家本回合无法进行任何通常召唤、反转召唤以及特殊召唤的誓约限制效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将无法进行通常召唤的誓约限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将无法进行特殊召唤的誓约限制效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 将无法进行反转召唤的誓约限制效果注册给玩家
	Duel.RegisterEffect(e3,tp)
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 切断连锁以处理自身发动完毕后的回收效果
		Duel.BreakEffect()
		-- 将此卡自身送回持有者卡组重新洗牌，而不是送去墓地
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
