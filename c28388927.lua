--B・F－毒針のニードル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「蜂军-毒针之针刺蜂」以外的1只「蜂军」怪兽加入手卡。
-- ②：把这张卡以外的自己场上1只昆虫族怪兽解放，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c28388927.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「蜂军-毒针之针刺蜂」以外的1只「蜂军」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28388927,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,28388927)
	e1:SetTarget(c28388927.thtg)
	e1:SetOperation(c28388927.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把这张卡以外的自己场上1只昆虫族怪兽解放，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28388927,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,28388928)
	e3:SetCost(c28388927.cost)
	e3:SetTarget(c28388927.distg)
	e3:SetOperation(c28388927.disop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：只接受「蜂军」怪兽、怪兽卡类型、可加入手卡，且卡名不是本卡（卡号28388927）的卡。
function c28388927.thfilter(c)
	return c:IsSetCard(0x12f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(28388927)
end
-- 效果①的发动条件检查和操作信息登记：发动时确认卡组存在符合检索条件的「蜂军」怪兽，并登记“将1张卡从卡组加入手卡”的操作。
function c28388927.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1只满足检索条件的「蜂军」怪兽，作为效果①能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c28388927.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁操作将执行“从卡组把1张卡加入手卡”的效果信息，供相关卡（如星尘龙、王家长眠之谷）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果①：玩家从卡组选择1只符合条件的「蜂军」怪兽加入手卡，并展示给对方玩家确认。
function c28388927.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，告知玩家正在选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 实际从卡组筛选并选择1张满足检索条件的「蜂军」怪兽（不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c28388927.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的「蜂军」怪兽加入其持有者的手卡，移动原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认，用于公开检索信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价处理：从自己场上把这张卡以外的1只昆虫族怪兽解放，作为发动代价。包含代价检查、选择与执行。
function c28388927.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1只满足解放条件（昆虫族）且不是本卡的怪兽，作为效果②能否发动的代价判定。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_INSECT) end
	-- 从自己场上选择1只昆虫族怪兽（不能是本卡）作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_INSECT)
	-- 将选择的怪兽解放，解放原因是代价（REASON_COST）。
	Duel.Release(rg,REASON_COST)
end
-- 效果②的取对象目标判定：选择对方场上1只表侧表示且可被无效的效果怪兽作为对象，并设置操作信息。
function c28388927.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 当效果处理中指定对象时，检查该目标是否位于对方主要怪兽区、由对方控制，并且是可被无效的表侧效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 发动时检查对方场上是否存在至少1只可被无效的表侧效果怪兽，作为效果②能否取对象的条件。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，告知玩家正在选择要无效的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 将选中的对方怪兽设为效果对象（取对象）。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果②处理：使对象怪兽的效果无效直到回合结束，同时无效与该怪兽相关的连锁。
function c28388927.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象（之前选择需要无效的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽相关的连锁无效化；若对象怪兽变为里侧表示，则该无效化重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那只怪兽的效果直到回合结束时无效。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
