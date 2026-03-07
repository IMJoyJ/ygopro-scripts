--電脳堺獣－鷲々
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要原本的种族·属性相同而卡名不同的怪兽在自己墓地有2只以上存在，场上的这张卡不会被战斗·效果破坏。
-- ②：把原本的种族·属性相同而卡名不同的2只怪兽从自己墓地除外，以场上1张卡为对象才能发动。那张卡送去墓地。
function c35252119.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要原本的种族·属性相同而卡名不同的怪兽在自己墓地有2只以上存在，场上的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(c35252119.indcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 把原本的种族·属性相同而卡名不同的2只怪兽从自己墓地除外，以场上1张卡为对象才能发动。那张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35252119,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,35252119)
	e3:SetCost(c35252119.tgcost)
	e3:SetTarget(c35252119.tgtg)
	e3:SetOperation(c35252119.tgop)
	c:RegisterEffect(e3)
end
-- 判断墓地中的怪兽是否满足条件，即存在至少一只怪兽与当前怪兽的种族和属性相同但卡名不同
function c35252119.indfilter(c,g)
	return g:IsExists(c35252119.indfilter2,1,c,c)
end
-- 判断两个怪兽是否具有相同的种族和属性，并且卡名不同
function c35252119.indfilter2(c,tc)
	return c:GetOriginalRace()&tc:GetOriginalRace()~=0
		and c:GetOriginalAttribute()&tc:GetOriginalAttribute()~=0
		and not c:IsCode(tc:GetCode())
end
-- 判断墓地中是否存在满足条件的怪兽组合，即至少存在两只怪兽满足种族和属性相同但卡名不同的条件
function c35252119.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取玩家墓地中所有怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:IsExists(c35252119.indfilter,1,nil,g)
end
-- 判断一个怪兽组是否满足条件，即组内所有怪兽的种族、属性都相同，且卡名各不相同
function c35252119.fselect(g)
	return g:GetClassCount(Card.GetOriginalRace)==1
		and g:GetClassCount(Card.GetOriginalAttribute)==1
		and g:GetClassCount(Card.GetCode)>1
end
-- 判断一个怪兽是否满足作为除外代价的条件，即为怪兽卡且可以除外
function c35252119.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检索满足条件的2只怪兽并除外作为效果的发动代价
function c35252119.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家墓地中所有可以作为除外代价的怪兽集合
	local g=Duel.GetMatchingGroup(c35252119.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(c35252119.fselect,2,2) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c35252119.fselect,false,2,2)
	-- 将选择的怪兽除外作为效果的发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标，选择场上一张可送去墓地的卡
function c35252119.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 判断是否场上存在可作为效果目标的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上一张卡作为效果的目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时的操作信息，确定要处理的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 执行效果，将目标卡送去墓地
function c35252119.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
