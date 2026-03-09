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
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「月光」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,48427163)
	-- 效果支付代价：将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c48427163.sptg)
	e2:SetOperation(c48427163.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查目标是否为表侧表示的「月光」怪兽
function c48427163.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf)
end
-- ①效果的费用函数：将此卡送去墓地作为费用
function c48427163.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行将此卡送去墓地的操作
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果的对象选择函数：选择场上1只「月光」怪兽作为对象
function c48427163.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48427163.filter(chkc) end
	-- 检查是否场上有满足条件的「月光」怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(c48427163.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只「月光」怪兽作为对象
	Duel.SelectTarget(tp,c48427163.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果的处理函数：使选中的怪兽攻击力上升1000
function c48427163.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个使对象怪兽攻击力上升1000的效果，并在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：检查手牌中是否含有「月光」怪兽且可特殊召唤
function c48427163.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的对象选择函数：确认场上是否有足够的空间并存在满足条件的「月光」怪兽
function c48427163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的「月光」怪兽
		and Duel.IsExistingMatchingCard(c48427163.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理函数：从手牌中选择并特殊召唤1只「月光」怪兽
function c48427163.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足条件的「月光」怪兽
	local g=Duel.SelectMatchingCard(tp,c48427163.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
