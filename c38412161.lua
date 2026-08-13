--霊塞術師 チョウサイ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把墓地的魔法·陷阱卡的效果发动。
-- ②：这张卡从场上送去墓地的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡除外。
function c38412161.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能把墓地的魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c38412161.actlimit)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38412161,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c38412161.remcon)
	e2:SetTarget(c38412161.remtg)
	e2:SetOperation(c38412161.remop)
	c:RegisterEffect(e2)
end
-- 作为①的判定函数：当正在发动的效果是魔法·陷阱卡的效果，且该效果来源卡在墓地时返回真，从而禁止该效果发动。
function c38412161.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ②的发动条件：此卡从场上送去墓地（即其之前所在区域为场上）时满足触发条件。
function c38412161.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②的取对象过滤：选择对方墓地的魔法·陷阱卡，且该卡可以被除外。
function c38412161.remfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- ②的发动时处理：检查对方墓地是否存在可除外的魔法·陷阱卡；存在则让玩家选择1张，设为对象并登记除外操作。
function c38412161.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c38412161.remfilter(chkc) end
	-- 合法性检查：对方墓地是否存在至少1张满足条件的魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c38412161.remfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示，用于选择对象的操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1张满足条件的魔法·陷阱卡，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c38412161.remfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 登记连锁处理信息：本效果处理时将对象卡除外，数量为1（若效果处理时对象仍合法则执行）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②的效果处理：取得之前选择的对象卡，若该卡仍与本效果关联，则将其除外。
function c38412161.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（对方墓地1张魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，处理原因为效果造成。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
