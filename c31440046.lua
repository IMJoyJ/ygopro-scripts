--プランキッズ・ロック
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己1张手卡除外，自己从卡组抽1张。那之后，可以从手卡·卡组把「调皮宝贝·岩石娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c31440046.initial_effect(c)
	-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己1张手卡除外，自己从卡组抽1张。那之后，可以从手卡·卡组把「调皮宝贝·岩石娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
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
-- 效果发动条件判断：此卡作为「调皮宝贝」怪兽的融合或连接素材从场上送去墓地的场合
function c31440046.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 效果目标阶段：确认当前玩家是否被允许执行抽卡效果，且手牌中存在能够除外的卡片，并设置相关效果分类操作信息
function c31440046.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标阶段检查：确认当前玩家当前是否可以执行抽卡效果
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
			-- 目标阶段检查：确认当前玩家手牌中是否存在至少1张能够被除外的卡片
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理时的除外操作信息，预计从手牌除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 设置连锁处理时的抽卡操作信息，预计抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤条件：筛选手卡·卡组中除「调皮宝贝·岩石娃」以外，能够被守备表示特殊召唤的「调皮宝贝」怪兽
function c31440046.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(31440046)
end
-- 效果处理阶段：让玩家选择除外1张手卡并抽1张卡，那之后可以选择从手卡·卡组将1只符合条件的怪兽守备表示特殊召唤
function c31440046.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要进行除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家在自己手牌中选择1张需要被除外的卡片
	local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选定的手牌除外，除外成功的前提下执行抽1张卡的操作，在两者都成功处理后继续进行后续效果
	if #rc>0 and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and Duel.Draw(tp,1,REASON_EFFECT)>0 then
		-- 获取当前玩家手卡和卡组中除「调皮宝贝·岩石娃」外，所有符合特殊召唤条件的「调皮宝贝」怪兽集合
		local g=Duel.GetMatchingGroup(c31440046.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 若存在可选的怪兽且己方场上有可用怪兽区域，则询问玩家是否选择进行特殊召唤
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(31440046,1)) then  --"是否特殊召唤？"
			-- 中断当前效果，使得随后的特殊召唤操作在规则时间点上不与先前的除外、抽卡视为同时发生
			Duel.BreakEffect()
			-- 向玩家发送提示信息，要求选择用于特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选择的怪兽以守备表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
