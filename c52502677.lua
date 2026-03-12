--剣闘獣アトリクス
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从卡组·额外卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽送去墓地才能发动。直到结束阶段，这张卡变成和送去墓地的怪兽相同等级，当作同名卡使用。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c52502677.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从卡组·额外卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽送去墓地才能发动。直到结束阶段，这张卡变成和送去墓地的怪兽相同等级，当作同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52502677,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	-- 判断是否为「剑斗兽」怪兽的效果特殊召唤成功
	e1:SetCondition(aux.gbspcon)
	e1:SetCost(c52502677.cost)
	e1:SetOperation(c52502677.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 女斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52502677,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c52502677.spcon)
	e2:SetCost(c52502677.spcost)
	e2:SetTarget(c52502677.sptg)
	e2:SetOperation(c52502677.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的「剑斗兽」怪兽（非本卡、非同名卡、等级≥1、可作为墓地代价）
function c52502677.costfilter(c,ec)
	return c:IsSetCard(0x1019) and not c:IsCode(52502677) and not c:IsCode(ec:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsAbleToGraveAsCost()
end
-- 处理效果发动时的费用支付，选择一张符合条件的「剑斗兽」怪兽送去墓地
function c52502677.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的「剑斗兽」怪兽可以作为墓地代价
	if chk==0 then return Duel.IsExistingMatchingCard(c52502677.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张符合条件的「剑斗兽」怪兽作为墓地代价
	local cg=Duel.SelectMatchingCard(tp,c52502677.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabelObject(cg:GetFirst())
end
-- 处理效果发动时的主效果，使本卡变为与送去墓地的怪兽相同等级和卡名
function c52502677.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local code=tc:GetCode()
	local lv=tc:GetLevel()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 设置效果使本卡变成与送去墓地的怪兽相同的卡名
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(lv)
	c:RegisterEffect(e2)
end
-- 判断是否在战斗阶段结束前有进行过战斗
function c52502677.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 处理效果发动时的费用支付，将本卡送回卡组
function c52502677.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将本卡送回卡组作为费用
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤函数，用于检索满足条件的「剑斗兽」怪兽（非本卡、为剑斗兽族、可特殊召唤）
function c52502677.filter(c,e,tp)
	return not c:IsCode(52502677) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的目标选择，检查是否有满足条件的「剑斗兽」怪兽可以特殊召唤
function c52502677.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否还有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查是否有满足条件的「剑斗兽」怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(c52502677.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的主效果，从卡组特殊召唤一张符合条件的「剑斗兽」怪兽
function c52502677.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一张符合条件的「剑斗兽」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c52502677.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡以特殊召唤方式送至场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
