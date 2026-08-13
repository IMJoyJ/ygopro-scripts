--バハムート・シャーク
-- 效果：
-- 水属性4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从额外卡组把1只3阶以下的水属性超量怪兽特殊召唤。这个效果的发动后，直到回合结束时这张卡不能攻击。
function c440556.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只水属性4星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从额外卡组把1只3阶以下的水属性超量怪兽特殊召唤。这个效果的发动后，直到回合结束时这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(440556,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c440556.spcost)
	e1:SetTarget(c440556.sptg)
	e1:SetOperation(c440556.spop)
	c:RegisterEffect(e1)
end
-- 代价判定与处理：若chk==0，仅检查这张卡能否由玩家tp取除1个超量素材作为代价；否则实际取除这张卡的1个超量素材。
function c440556.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选额外卡组中符合条件的怪兽：阶级3以下、水属性、能够被特殊召唤，且额外卡组怪兽特殊召唤到场上有可用区域。
function c440556.filter(c,e,tp)
	return c:IsRankBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 追加判断额外卡组怪兽特殊召唤时是否有可用空格（检查额外怪兽区或因额外卡组怪兽离场后腾出的位置），确保有1个以上可用区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动目标阶段：先确认额外卡组存在至少1只符合条件的怪兽，然后登记本次操作信息为从额外卡组特殊召唤1只怪兽。
function c440556.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于发动合法性检查阶段（chk==0），则检索额外卡组是否存在至少1张满足c440556.filter条件的卡，作为能否发动的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c440556.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本次效果将进行1次从额外卡组的特殊召唤，用于连锁判定和时点触发。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：由玩家从额外卡组选择1只符合条件的怪兽特殊召唤到其场上；召唤成功后，为这张卡附加直到回合结束时不能攻击的效果。
function c440556.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示选择提示消息：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组筛选并选择1张符合filter条件的怪兽卡（在效果处理时选择，属于不取对象的选择）。
	local g=Duel.SelectMatchingCard(tp,c440556.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到玩家tp的场上（已通过可特殊召唤检查，故不追加检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
