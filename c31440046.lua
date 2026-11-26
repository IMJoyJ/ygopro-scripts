--プランキッズ・ロック
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己1张手卡除外，自己从卡组抽1张。那之后，可以从手卡·卡组把「调皮宝贝·岩石娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
function c31440046.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。 ①：这张卡作为「调皮宝贝」怪兽的所用融合素材或者所用连接素材送去墓地的场合才能发动。自己1张手卡除外，自己从卡组抽1张。那之后，可以从手卡·卡组把「调皮宝贝·岩石娃」以外的1只「调皮宝贝」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31440046,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31440046)
	e1:SetCondition(c31440046.reccon)
	e1:SetTarget(c31440046.rectg)
	e1:SetOperation(c31440046.recop)
	c:RegisterEffect(e1)
end
-- 发动条件检查：确认这张卡当前位于墓地、因作为「调皮宝贝」怪兽的融合或连接召唤素材而送去墓地（且非返回墓地）
function c31440046.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x120) and r&(REASON_FUSION+REASON_LINK)~=0 and not c:IsReason(REASON_RETURN)
end
-- 发动检测：确认己方可以抽1张卡，且己方手卡存在至少1张可除外的卡
function c31440046.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方玩家可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
			-- 发动条件检查（后半）：确认己方手卡中存在至少1张可以除外的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	-- 登记连锁的除外操作信息，预计将己方1张手卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 登记连锁的抽卡操作信息，预计使己方抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 筛选条件：检查卡片是否为「调皮宝贝·岩石娃」以外、能以表侧守备表示特殊召唤的「调皮宝贝」怪兽
function c31440046.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(31440046)
end
-- 效果处理流程：先让己方除外1张手卡并抽1张卡，之后在己方怪兽区有空位时可选从手卡·卡组把1只其他「调皮宝贝」怪兽表侧守备表示特殊召唤
function c31440046.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方提示选择要除外的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让己方从己方手卡选择1张可除外的卡
	local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选手卡以效果表侧除外，并在除外与己方抽1张卡均成功后继续后续处理
	if #rc>0 and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and Duel.Draw(tp,1,REASON_EFFECT)>0 then
		-- 获取己方手卡与卡组中满足特殊召唤条件的其他「调皮宝贝」怪兽组
		local g=Duel.GetMatchingGroup(c31440046.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- 确认存在可特召的怪兽且己方怪兽区有空位后，询问己方是否执行特殊召唤
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(31440046,1)) then  --"是否特殊召唤？"
			-- 中断效果处理，使后续的特殊召唤与前面的除外手卡·抽卡视为不同时处理
			Duel.BreakEffect()
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将所选「调皮宝贝」怪兽以表侧守备表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
