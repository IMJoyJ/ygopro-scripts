--マジェスペクター・トルネード
-- 效果：
-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
function c36183881.initial_effect(c)
	-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c36183881.cost)
	e1:SetTarget(c36183881.target)
	e1:SetOperation(c36183881.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选魔法师族且风属性的怪兽
function c36183881.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 检查玩家场上是否存在至少1张满足条件的可解放的魔法师族·风属性怪兽，并选择1张进行解放
function c36183881.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的魔法师族·风属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c36183881.cfilter,1,nil) end
	-- 从玩家场上选择1张满足条件的可解放的魔法师族·风属性怪兽
	local g=Duel.SelectReleaseGroup(tp,c36183881.cfilter,1,1,nil)
	-- 以REASON_COST原因解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标为对方场上的1只可除外的怪兽
function c36183881.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在至少1只可除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息为CATEGORY_REMOVE，表示该效果会除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽除外
function c36183881.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以正面表示形式将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
