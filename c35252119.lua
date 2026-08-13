--電脳堺獣－鷲々
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要原本的种族·属性相同而卡名不同的怪兽在自己墓地有2只以上存在，场上的这张卡不会被战斗·效果破坏。
-- ②：把原本的种族·属性相同而卡名不同的2只怪兽从自己墓地除外，以场上1张卡为对象才能发动。那张卡送去墓地。
function c35252119.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要原本的种族·属性相同而卡名不同的怪兽在自己墓地有2只以上存在，场上的这张卡不会被战斗·效果破坏。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：把原本的种族·属性相同而卡名不同的2只怪兽从自己墓地除外，以场上1张卡为对象才能发动。那张卡送去墓地。
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
-- 判断墓地怪兽组g中是否存在至少1只与c原本种族·属性相同且卡名不同的怪兽，用于①效果的抗性条件。
function c35252119.indfilter(c,g)
	return g:IsExists(c35252119.indfilter2,1,c,c)
end
-- 判断两张卡c和tc是否满足：原本种族相同、原本属性相同、卡名不同（以当前卡号判断）。
function c35252119.indfilter2(c,tc)
	return c:GetOriginalRace()&tc:GetOriginalRace()~=0
		and c:GetOriginalAttribute()&tc:GetOriginalAttribute()~=0
		and not c:IsCode(tc:GetCode())
end
-- ①效果的适用条件：自己墓地存在至少2只原本种族·属性相同而卡名不同的怪兽。
function c35252119.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 取得自己墓地中的所有怪兽卡，用于①效果的条件检查。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:IsExists(c35252119.indfilter,1,nil,g)
end
-- 用于cost选择的筛选：选出的怪兽集合g必须原本种族相同、原本属性相同，且卡名种类数大于1（即至少2张卡名不同）。
function c35252119.fselect(g)
	return g:GetClassCount(Card.GetOriginalRace)==1
		and g:GetClassCount(Card.GetOriginalAttribute)==1
		and g:GetClassCount(Card.GetCode)>1
end
-- cost候选筛选：怪兽卡且可以作为发动代价从墓地除外。
function c35252119.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动代价：从自己墓地选择2只原本种族·属性相同且卡名不同的怪兽除外，不满足条件则不能发动。
function c35252119.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己墓地中可作为除外代价的怪兽集合。
	local g=Duel.GetMatchingGroup(c35252119.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroup(c35252119.fselect,2,2) end
	-- 向玩家显示选择要除外的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c35252119.fselect,false,2,2)
	-- 将选中的2只怪兽表侧表示除外，作为②效果发动的代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ②效果的目标处理函数：检查合法性、选择场上1张卡为对象，并登记送去墓地的操作信息。
function c35252119.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 发动时检查：场上是否存在至少1张可以被送去墓地的卡作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择要送去墓地的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果处理确定会将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果处理：取得对象卡，若对象仍与效果关联，则将其送去墓地。
function c35252119.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
