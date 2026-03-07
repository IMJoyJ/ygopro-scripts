--プランキッズ・ロック
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己1张手卡除外，自己从卡组抽1张。那之后，可以从手卡·卡组把「调皮宝贝·岩石娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c31440046.initial_effect(c)
	-- 效果原文内容：①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31440046,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31440046)
	e1:SetCondition(c31440046.reccon)
	e1:SetTarget(c31440046.rectg)
	e1:SetOperation(c31440046.recop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断此卡是否因作为融合或连接素材而进入墓地
function c31440046.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&REASON_FUSION+REASON_LINK~=0
end
-- 规则层面作用：检查玩家是否可以抽卡且手牌中是否存在可除外的卡
function c31440046.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
			-- 规则层面作用：检查玩家手牌中是否存在至少1张可除外的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：设置操作信息，表示将除外1张手卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 规则层面作用：设置操作信息，表示将让玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面作用：定义特殊召唤的过滤条件，即为调皮宝贝卡组且不是岩石娃本身
function c31440046.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(31440046)
end
-- 规则层面作用：执行效果处理，包括选择除外手卡、抽卡、判断是否特殊召唤
function c31440046.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：选择1张手卡除外
	local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 规则层面作用：确认已成功除外卡并抽卡后，继续处理后续效果
	if #rc>0 and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and Duel.Draw(tp,1,REASON_EFFECT)>0 then
		-- 规则层面作用：获取满足特殊召唤条件的调皮宝贝怪兽
		local g=Duel.GetMatchingGroup(c31440046.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 规则层面作用：判断是否有足够召唤位置并询问玩家是否进行特殊召唤
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(31440046,1)) then  --"是否特殊召唤？"
			-- 规则层面作用：中断当前连锁处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 规则层面作用：提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 规则层面作用：将符合条件的怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
