--ジャック・ワイバーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只机械族怪兽和这张卡除外，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c23850421.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上1只机械族怪兽和这张卡除外，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23850421,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23850421)
	e1:SetCost(c23850421.spcost)
	e1:SetTarget(c23850421.sptg)
	e1:SetOperation(c23850421.spop)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：筛选表侧表示且为机械族、并可作为代价除外；用于选择自己场上1只机械族怪兽作为发动代价。
function c23850421.costfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost()
end
-- 代价函数在发动合法性检查时确认：这张卡本身可作为代价除外，且自己场上存在至少1只满足costfilter的机械族怪兽可供选择。
function c23850421.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 确认场上存在至少1只除这张卡自身以外、满足costfilter的机械族怪兽，可作为发动代价。
		and Duel.IsExistingMatchingCard(c23850421.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作玩家发出选择除外卡片的提示信息，提示文字为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只除自身以外、满足costfilter的机械族怪兽作为代价对象。
	local rg=Duel.SelectMatchingCard(tp,c23850421.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	rg:AddCard(e:GetHandler())
	-- 将选中的机械族怪兽和这张卡自身以表侧表示除外，作为发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤对象的筛选条件：选择自己墓地中暗属性且可以被效果特殊召唤的怪兽。
function c23850421.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：先校验连锁对象是否合法，再确认墓地存在合法目标；随后提示并选择1只墓地暗属性怪兽为对象，并设置特殊召唤的操作信息。
function c23850421.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23850421.spfilter(chkc,e,tp) end
	-- 在效果发动的合法性检查中，确认自己墓地存在至少1只满足spfilter且可作为效果对象的暗属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c23850421.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家发出选择特殊召唤对象的提示信息，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter的暗属性怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c23850421.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：本次效果将进行特殊召唤，对象为g中的1只怪兽，供相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：取得特殊召唤对象，若其仍与本次效果关联，则将其表侧表示特殊召唤到自己场上。
function c23850421.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个效果对象，即被选择的那只墓地暗属性怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 由tp玩家以表侧表示将对象怪兽特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
