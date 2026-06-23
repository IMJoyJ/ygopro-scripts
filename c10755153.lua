--ガーディアン・シール
-- 效果：
-- 当自己场上存在「流星之弓-烨焰」时才能召唤·反转召唤·特殊召唤。将1张这张卡身上装备的自己的装备卡送去墓地，破坏对方场上1只怪兽。
function c10755153.initial_effect(c)
	-- 当自己场上不存在「流星之弓-烨焰」时不能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c10755153.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「流星之弓-烨焰」时才能特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c10755153.sumlimit)
	c:RegisterEffect(e3)
	-- 破坏对方场上1只怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10755153,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c10755153.descost)
	e4:SetTarget(c10755153.destg)
	e4:SetOperation(c10755153.desop)
	c:RegisterEffect(e4)
end
-- 用于过滤场上存在的「流星之弓-烨焰」卡片
function c10755153.cfilter(c)
	return c:IsFaceup() and c:IsCode(95638658)
end
-- 判断是否满足召唤条件
function c10755153.sumcon(e)
	-- 检查自己场上是否不存在「流星之弓-烨焰」
	return not Duel.IsExistingMatchingCard(c10755153.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 判断是否满足特殊召唤条件
function c10755153.sumlimit(e,se,sp,st,pos,tp)
	-- 检查特殊召唤者场上是否存在「流星之弓-烨焰」
	return Duel.IsExistingMatchingCard(c10755153.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 用于过滤自身装备的装备卡
function c10755153.costfilter(c,ec)
	return c:IsFaceup() and c:GetEquipTarget()==ec and c:IsAbleToGraveAsCost()
end
-- 破坏效果的费用支付处理
function c10755153.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付破坏费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c10755153.costfilter,tp,LOCATION_SZONE,0,1,nil,e:GetHandler()) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择一张自身装备的装备卡送去墓地
	local g=Duel.SelectMatchingCard(tp,c10755153.costfilter,tp,LOCATION_SZONE,0,1,1,nil,e:GetHandler())
	-- 将选中的装备卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 破坏效果的目标选择处理
function c10755153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否满足选择破坏目标的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1只怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行处理
function c10755153.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
