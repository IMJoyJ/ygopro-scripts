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
-- 此过滤函数用于判断卡片是否为魔法师族·风属性怪兽，即满足解放素材的要求。
function c36183881.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 该效果发动时的代价处理：检查、选择并解放自己场上1只魔法师族·风属性怪兽作为发动代价。
function c36183881.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，确认自己场上是否存在至少1只可解放的魔法师族·风属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c36183881.cfilter,1,nil) end
	-- 发动时选择自己场上1只魔法师族·风属性怪兽作为解放的代价素材。
	local g=Duel.SelectReleaseGroup(tp,c36183881.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为效果发动的代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 该效果发动时的对象选择处理：指定对方场上1只可除外的怪兽为效果对象，并设置除外相关的操作信息。
function c36183881.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在效果发动合法性检测阶段，确认对方场上是否存在至少1只可以成为对象且能被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要除外的卡”的提示文字，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可除外的怪兽作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的处理信息：将对象卡除外（CATEGORY_REMOVE），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理阶段：取得之前选择的对象，若对象仍与效果相关，则将其除外。
function c36183881.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，除外原因为效果处理（REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
