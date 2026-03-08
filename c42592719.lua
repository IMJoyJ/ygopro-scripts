--剣闘獣アレクサンデル
-- 效果：
-- 「剑斗兽 双斗」以外的效果不能把这张卡特殊召唤。特殊召唤的这张卡只要在自己场上表侧表示存在，不受魔法的效果的影响。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 亚历山大」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c42592719.initial_effect(c)
	-- 效果原文：特殊召唤的这张卡只要在自己场上表侧表示存在，不受魔法的效果的影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c42592719.imcon)
	e1:SetValue(c42592719.imfilter)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 亚历山大」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42592719,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c42592719.spcon)
	e2:SetCost(c42592719.spcost)
	e2:SetTarget(c42592719.sptg)
	e2:SetOperation(c42592719.spop)
	c:RegisterEffect(e2)
	-- 效果原文：「剑斗兽 双斗」以外的效果不能把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c42592719.splimit)
	c:RegisterEffect(e3)
end
-- 规则层面：允许通过灵摆召唤或特殊召唤「剑斗兽 双斗」来特殊召唤此卡。
function c42592719.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(31247589) or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 规则层面：此卡必须通过特殊召唤方式出场才能触发免疫魔法效果。
function c42592719.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 规则层面：免疫魔法卡的效果。
function c42592719.imfilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 规则层面：战斗阶段结束时才能发动此效果。
function c42592719.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 规则层面：支付将此卡送入墓地的代价。
function c42592719.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 规则层面：将此卡送入卡组并洗牌。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 规则层面：筛选卡组中非「剑斗兽 亚历山大」且属于「剑斗兽」卡组的怪兽。
function c42592719.filter(c,e,tp)
	return not c:IsCode(42592719) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：判断是否满足发动条件，包括场上有空位和卡组中存在符合条件的怪兽。
function c42592719.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 规则层面：判断卡组中是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c42592719.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行特殊召唤操作，选择并特殊召唤符合条件的怪兽。
function c42592719.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断场上是否有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：从卡组中选择符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c42592719.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面：将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
