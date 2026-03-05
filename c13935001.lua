--月光小夜曲舞踊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有融合怪兽融合召唤时，以那之内的1只为对象才能发动。以下效果适用。
-- ●在对方场上把1只「月光衍生物」（兽战士族·暗·4星·攻/守2000）特殊召唤。
-- ●作为对象的怪兽的攻击力上升对方场上的怪兽数量×500。
-- ②：自己主要阶段，把墓地的这张卡除外才能发动。选自己1张手卡送去墓地，从卡组把1只「月光」怪兽特殊召唤。
function c13935001.initial_effect(c)
	-- ①：自己场上有融合怪兽融合召唤时，以那之内的1只为对象才能发动。以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●在对方场上把1只「月光衍生物」（兽战士族·暗·4星·攻/守2000）特殊召唤。
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
	-- ●作为对象的怪兽的攻击力上升对方场上的怪兽数量×500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13935001,2))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,13935001)
	e4:SetCondition(c13935001.spcon)
	-- 把墓地的这张卡除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c13935001.sptg)
	e4:SetOperation(c13935001.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选满足条件的融合怪兽
function c13935001.atkfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
-- 效果处理时的target阶段，用于选择对象怪兽
function c13935001.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c13935001.atkfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c13935001.atkfilter,1,nil,e,tp)
		-- 检查对方场上是否有空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤月光衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13935002,0xdf,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEASTWARRIOR,ATTRIBUTE_DARK,POS_FACEUP,1-tp) end
	if eg:GetCount()==1 then
		-- 设置连锁对象为融合召唤的怪兽
		Duel.SetTargetCard(eg)
	else
		-- 提示玩家选择对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=eg:FilterSelect(tp,c13935001.atkfilter,1,1,nil,e,tp)
		-- 设置连锁对象为选中的怪兽
		Duel.SetTargetCard(g)
	end
	-- 设置操作信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 效果处理时的operation阶段，用于处理效果
function c13935001.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤月光衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13935002,0xdf,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEASTWARRIOR,ATTRIBUTE_DARK,POS_FACEUP,1-tp) then
		-- 创建月光衍生物
		local token=Duel.CreateToken(tp,13935002)
		-- 将月光衍生物特殊召唤到对方场上
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
	-- 获取当前连锁对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取对方场上的怪兽数量
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 给对象怪兽增加攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否在主要阶段发动
function c13935001.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在主要阶段发动
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤函数，用于筛选「月光」怪兽
function c13935001.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的target阶段，用于选择特殊召唤目标
function c13935001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否有可送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil)
		-- 检查卡组中是否有「月光」怪兽
		and Duel.IsExistingMatchingCard(c13935001.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤「月光」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的operation阶段，用于处理效果
function c13935001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择手牌中的一张卡送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	-- 确认卡送去墓地成功并进入墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 检查是否有足够的特殊召唤位置
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择特殊召唤的「月光」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择卡组中的一只「月光」怪兽
		local g=Duel.SelectMatchingCard(tp,c13935001.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「月光」怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
