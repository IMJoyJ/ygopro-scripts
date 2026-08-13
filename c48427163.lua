--月光紫蝶
-- 效果：
-- 「月光紫蝶」的②的效果1回合只能使用1次。
-- ①：把自己的手卡·场上的这张卡送去墓地，以自己场上1只「月光」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「月光」怪兽特殊召唤。
function c48427163.initial_effect(c)
	-- ①：把自己的手卡·场上的这张卡送去墓地，以自己场上1只「月光」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCost(c48427163.atkcost)
	e1:SetTarget(c48427163.atktg)
	e1:SetOperation(c48427163.atkop)
	c:RegisterEffect(e1)
	-- 「月光紫蝶」的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从手卡把1只「月光」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,48427163)
	-- 设置②效果的发动代价：把墓地的这张卡除外（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c48427163.sptg)
	e2:SetOperation(c48427163.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：选择对象须为表侧表示的「月光」怪兽。
function c48427163.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf)
end
-- 定义①效果的发动代价：将这张卡从手卡或场上送去墓地。
function c48427163.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价：将这张卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义①效果的目标：以自己场上1只表侧表示的「月光」怪兽为对象。
function c48427163.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48427163.filter(chkc) end
	-- 发动时确认自己场上是否存在1只表侧表示「月光」怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c48427163.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 弹出选择提示，要求玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「月光」怪兽作为效果对象。
	Duel.SelectTarget(tp,c48427163.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：对象怪兽的攻击力直到回合结束时上升1000。
function c48427163.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果的特殊召唤过滤器：手卡的「月光」怪兽且可以被特殊召唤。
function c48427163.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：自己场上存在可用怪兽区域，且手卡有1只「月光」怪兽可以特殊召唤。
function c48427163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡中是否存在1只满足特殊召唤条件的「月光」怪兽。
		and Duel.IsExistingMatchingCard(c48427163.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本效果将进行特殊召唤，用于连锁检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：从手卡选择1只「月光」怪兽特殊召唤。
function c48427163.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若己方场上没有可用怪兽区域则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中1只满足条件的「月光」怪兽。
	local g=Duel.SelectMatchingCard(tp,c48427163.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「月光」怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
