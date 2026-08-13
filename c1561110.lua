--ABC－ドラゴン・バスター
-- 效果：
-- 「A-突击核」＋「B-破坏龙兽」＋「C-粉碎翼龙」
-- 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
-- ①：自己·对方回合1次，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡除外。
-- ②：对方回合，把这张卡解放，以自己的除外状态的3只机械族·光属性同盟怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
function c1561110.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以「A-突击核」(30012506)、「B-破坏龙兽」(77411244)、「C-粉碎翼龙」(3405259)为指定素材的融合召唤手续，对应召唤条件中的融合素材要求。
	aux.AddFusionProcCode3(c,30012506,77411244,3405259,true,true)
	-- 注册接触融合召唤手续：将己方场上·墓地的上述A/B/C素材卡除外（作为COST），从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 「A-突击核」＋「B-破坏龙兽」＋「C-粉碎翼龙」 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c1561110.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合1次，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1561110,0))  --"丢弃1张手卡，把场上1张卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c1561110.rmcost)
	e3:SetTarget(c1561110.rmtg)
	e3:SetOperation(c1561110.rmop)
	c:RegisterEffect(e3)
	-- ②：对方回合，把这张卡解放，以自己的除外状态的3只机械族·光属性同盟怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1561110,1))  --"把这张卡解放，把除外的同盟怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c1561110.spcon2)
	e4:SetCost(c1561110.spcost2)
	e4:SetTarget(c1561110.sptg2)
	e4:SetOperation(c1561110.spop2)
	c:RegisterEffect(e4)
end
c1561110.has_text_type=TYPE_UNION
-- 特殊召唤条件判定：效果持有者（这张卡）不在额外卡组时判定为允许特殊召唤，用于配合召唤手续限制此卡只能通过正规的融合/接触融合手续出场。
function c1561110.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 效果①的代价函数：先确认手牌中有可丢弃的卡，然后从手卡丢弃1张卡作为发动代价。
function c1561110.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：判定手牌中是否有1张满足可丢弃条件的卡，作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：由玩家从手卡选择1张卡丢弃（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的取对象处理：先确认场上有1张可除外的卡，然后选择1张指定为对象，并写入除外处理信息。
function c1561110.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 目标检查：确认场上（双方）是否存在至少1张可以被除外的卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家进行选择，显示“请选择要除外的卡”的选卡消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从双方场上选择1张可除外的卡，并将其设为这张效果的连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁的除外操作信息，告知系统将把所选对象除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的发动处理：若对象仍与本次效果关联，则将那张卡表侧表示除外。
function c1561110.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①处理时对象中的第一张卡（即被选择的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，作为效果处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：仅在对方回合才能发动。
function c1561110.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是这张卡的控制者，即满足“对方回合”的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的代价处理：确认此卡可解放后，将其解放作为发动代价。
function c1561110.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际解放这张卡，作为效果②的发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的选卡过滤条件：需要在除外状态、表侧表示、机械族·光属性·同盟怪兽，且可作为效果对象并能够被特殊召唤。
function c1561110.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_UNION) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标选择处理：从自己除外状态的怪兽中筛选符合条件的同盟怪兽，选择其中3只卡名不同的怪兽作为对象，并登记特殊召唤信息。
function c1561110.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己除外状态中满足机械族·光属性·同盟怪兽条件的全部卡片组。
	local g=Duel.GetMatchingGroup(c1561110.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then
		-- 计算自己场上可用的主要怪兽区空格数量，用于判断能否同时特殊召唤3只怪兽。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>2
	end
	-- 提示玩家进行选择，显示“请选择要特殊召唤的卡”的选卡消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选组中选出3张卡名各不相同的怪兽作为特殊召唤对象（同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选出的3张怪兽设为当前连锁的对象，供效果处理时使用。
	Duel.SetTargetCard(sg)
	-- 登记本次连锁的特殊召唤操作信息，告知系统将特殊召唤这3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
-- 效果②的发动处理：获取对象怪兽、可用格子数，按可用格子数量特殊召唤；若格子不足则选出能召唤的数量，剩余怪兽送去墓地。
function c1561110.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上可用的主要怪兽区空格数量，用于决定能特殊召唤几只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 从当前连锁中取得效果②选择的对象卡组，并筛选出仍然与本次效果关联的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 当对象数量不超过可用格子数时，将全部对象怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家进行选择，显示“请选择要特殊召唤的卡”的选卡消息（用于格子不足时的选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将格子不足时选出的一部分对象怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 由于怪兽区格子不足，无法特殊召唤的剩余对象怪兽依照规则送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
