--フィッシュアンドキックス
-- 效果：
-- 从游戏中除外的自己的鱼族·海龙族·水族怪兽有3只以上的场合，选择场上存在的1张卡发动。选择的卡从游戏中除外。
function c32703716.initial_effect(c)
	-- 从游戏中除外的自己的鱼族·海龙族·水族怪兽有3只以上的场合，选择场上存在的1张卡发动。选择的卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c32703716.condition)
	e1:SetTarget(c32703716.target)
	e1:SetOperation(c32703716.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于检查卡片是否为表侧表示且种族属于鱼族、海龙族或水族。
function c32703716.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 发动条件：检查自己除外区是否存在至少3张表侧表示且种族为鱼族、海龙族或水族的怪兽。
function c32703716.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己除外区是否存在至少3张满足cfilter过滤条件的卡。
	return Duel.IsExistingMatchingCard(c32703716.cfilter,tp,LOCATION_REMOVED,0,3,nil)
end
-- 效果发动时的目标选择流程：确认对象合法、提示选择、选择场上1张可除外的卡并设置除外相关的操作信息。
function c32703716.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 发动时合法目标检查：确认场上存在至少1张可以被除外的卡（且不包含效果发动者自身）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让发动玩家从双方场上选择1张可以除外的卡作为对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息，标明将进行1张卡的除外处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：取得发动时选择的对象卡，若该卡仍与效果关联，则将其除外。
function c32703716.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以表侧表示的形式，因效果原因将对象卡从游戏中除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
