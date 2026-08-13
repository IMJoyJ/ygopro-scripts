--ゾンビ・マスター
-- 效果：
-- ①：1回合1次，从手卡把1只怪兽送去墓地，以自己或者对方的墓地1只4星以下的不死族怪兽为对象才能发动。那只不死族怪兽特殊召唤。这个效果在这张卡在怪兽区域表侧表示存在的场合才能发动和处理。
function c17259470.initial_effect(c)
	-- ①：1回合1次，从手卡把1只怪兽送去墓地，以自己或者对方的墓地1只4星以下的不死族怪兽为对象才能发动。那只不死族怪兽特殊召唤。这个效果在这张卡在怪兽区域表侧表示存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17259470,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c17259470.spcost)
	e1:SetTarget(c17259470.sptg)
	e1:SetOperation(c17259470.spop)
	c:RegisterEffect(e1)
end
-- 代价过滤函数：从手卡选出1只可以作为代价送去墓地的怪兽卡。
function c17259470.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价函数：从手卡挑选1只怪兽送入墓地作为发动代价；若是发动前检查（chk==0）则先确认手卡中是否有满足条件的怪兽，然后选择并送墓。
function c17259470.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认手卡中至少存在1只满足代价条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c17259470.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡中选择1只符合条件的怪兽（用于支付代价）。
	local g=Duel.SelectMatchingCard(tp,c17259470.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽以代价原因（REASON_COST）送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 对象过滤函数：墓地中满足4星以下、不死族、且可以被特殊召唤的怪兽。
function c17259470.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的选定函数：确认自身怪兽区域有空格且墓地存在可选对象；若为连锁处理中的对象检查，则验证该对象位于墓地且满足过滤条件。
function c17259470.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c17259470.filter(chkc,e,tp) end
	-- 发动合法性检查：己方主要怪兽区域必须存在可用的空格，否则无法发动特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：在双方墓地中至少存在1只满足条件且能成为效果对象的不死族怪兽。
		and Duel.IsExistingTarget(c17259470.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 弹出提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从双方墓地选择1只符合条件的怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c17259470.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将特殊召唤1只怪兽（用于后续时点/连锁的判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：效果处理时再次确认发动者仍表侧表示且效果、对象均有效，然后将对象怪兽表侧攻击表示特殊召唤到己方场上。
function c17259470.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这个效果发动时所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将对象不死族怪兽特殊召唤到己方场上，表示形式为表侧攻击表示。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
