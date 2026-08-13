--TG ワーウルフ
-- 效果：
-- ①：4星以下的怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 狼人」以外的1只「科技属」怪兽加入手卡。
function c293542.initial_effect(c)
	-- ①：4星以下的怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(293542,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c293542.spcon)
	e1:SetTarget(c293542.sptg)
	e1:SetOperation(c293542.spop)
	c:RegisterEffect(e1)
	-- 场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c293542.regop)
	c:RegisterEffect(e2)
end
-- 筛选函数：判定特殊召唤成功的怪兽是否为表侧表示且等级4以下。
function c293542.cfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 特殊召唤成功时，若本次特殊召唤的怪兽中存在至少1只表侧表示且等级4以下的怪兽，则满足①的发动条件。
function c293542.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c293542.cfilter,1,nil)
end
-- 发动时判定：我方主要怪兽区有空位，且这张卡自身能够被特殊召唤。
function c293542.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果处理的信息为“特殊召唤这张卡”，便于相关效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果保持关联，则将其特殊召唤。
function c293542.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 若这张卡从场上被破坏并送去墓地，则在墓地注册一个结束阶段才能发动的检索效果，且在当回合结束阶段可用。
function c293542.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- ②：从卡组把「科技属 狼人」以外的1只「科技属」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(293542,1))  --"检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c293542.thtg)
		e1:SetOperation(c293542.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索筛选条件：持有「科技属」字段、不是「科技属 狼人」、是怪兽且能够加入手卡的卡。
function c293542.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(293542) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时确认卡组存在符合条件的「科技属」怪兽，并设置“加入手卡”的操作信息。
function c293542.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方卡组中至少存在1张符合条件的「科技属」怪兽可供检索。
	if chk==0 then return Duel.IsExistingMatchingCard(c293542.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理为从卡组将1张卡加入手卡（不取对象，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张符合条件的「科技属」怪兽加入手卡，并让对手确认。
function c293542.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张满足过滤条件的「科技属」怪兽。
	local g=Duel.SelectMatchingCard(tp,c293542.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的检索结果展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
