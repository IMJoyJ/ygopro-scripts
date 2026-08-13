--月光小夜曲舞踊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有融合怪兽融合召唤时，以那之内的1只为对象才能发动。以下效果适用。
-- ●在对方场上把1只「月光衍生物」（兽战士族·暗·4星·攻/守2000）特殊召唤。
-- ●作为对象的怪兽的攻击力上升对方场上的怪兽数量×500。
-- ②：自己主要阶段，把墓地的这张卡除外才能发动。选自己1张手卡送去墓地，从卡组把1只「月光」怪兽特殊召唤。
function c13935001.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有融合怪兽融合召唤时，以那之内的1只为对象才能发动。以下效果适用。●在对方场上把1只「月光衍生物」（兽战士族·暗·4星·攻/守2000）特殊召唤。●作为对象的怪兽的攻击力上升对方场上的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13935001,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c13935001.tktg)
	e2:SetOperation(c13935001.tkop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段，把墓地的这张卡除外才能发动。选自己1张手卡送去墓地，从卡组把1只「月光」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13935001,2))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,13935001)
	e4:SetCondition(c13935001.spcon)
	-- 设置②效果的发动代价为把墓地的这张卡除外（由aux.bfgcost函数处理）。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c13935001.sptg)
	e4:SetOperation(c13935001.spop)
	c:RegisterEffect(e4)
end
-- 定义①效果可选择的融合怪兽的过滤条件：表侧表示、是融合怪兽、通过融合召唤成功、由自己控制、且能成为效果对象。
function c13935001.atkfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
-- ①效果的发动条件和对象选择：检查本次融合召唤成功的怪兽中存在符合条件的对象，对方场上有空位且自己可以特殊召唤月光衍生物，并在发动时选择其中1只作为对象。
function c13935001.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c13935001.atkfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c13935001.atkfilter,1,nil,e,tp)
		-- 检查对方主要怪兽区是否有空闲格子，用于特殊召唤月光衍生物。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查自己是否可以将「月光衍生物」以表侧表示特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13935002,0xdf,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEASTWARRIOR,ATTRIBUTE_DARK,POS_FACEUP,1-tp) end
	if eg:GetCount()==1 then
		-- 当融合召唤成功的怪兽只有1只时，直接将该怪兽设置为效果对象。
		Duel.SetTargetCard(eg)
	else
		-- 提示玩家选择表侧表示的卡（用于选择对象）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local g=eg:FilterSelect(tp,c13935001.atkfilter,1,1,nil,e,tp)
		-- 将通过筛选选出的1只融合怪兽设置为效果对象。
		Duel.SetTargetCard(g)
	end
	-- 设置效果处理信息：包含特殊召唤，预计特殊召唤1只怪兽（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置效果处理信息：包含生成衍生物，预计由自己生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- ①效果处理：在对方场上特殊召唤「月光衍生物」，并让作为对象的怪兽攻击力上升对方场上怪兽数量×500。
function c13935001.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认对方主要怪兽区有空位。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 效果处理时再次确认自己可以特殊召唤「月光衍生物」到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13935002,0xdf,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEASTWARRIOR,ATTRIBUTE_DARK,POS_FACEUP,1-tp) then
		-- 创建1只「月光衍生物」（卡号13935002），持有者为自己。
		local token=Duel.CreateToken(tp,13935002)
		-- 将生成的「月光衍生物」表侧表示特殊召唤到对方场上（1-tp）。
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取对方场上的怪兽数量，用于计算攻击力上升值。
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- ●作为对象的怪兽的攻击力上升对方场上的怪兽数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：自己回合的主要阶段（主要阶段1或主要阶段2）才能发动。
function c13935001.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是己方回合且处于主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 定义②效果从卡组特殊召唤的过滤条件：是「月光」怪兽且可以被特殊召唤。
function c13935001.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标检查：自己怪兽区有空位、手牌有至少1张可送墓的卡、卡组有至少1只符合条件的「月光」怪兽。
function c13935001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：手牌存在至少1张可以送去墓地的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil)
		-- 发动条件检查：卡组存在至少1只符合条件的「月光」怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c13935001.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：先把1张手卡送去墓地，然后从卡组特殊召唤1只「月光」怪兽。
function c13935001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌选择1张卡送去墓地。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	-- 确认选中的卡确实被效果成功送去了墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 特殊召唤前再次确认自己怪兽区有空位，否则中断处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只符合条件的「月光」怪兽。
		local g=Duel.SelectMatchingCard(tp,c13935001.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「月光」怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
