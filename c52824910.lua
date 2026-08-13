--カイザー・グライダー
-- 效果：
-- ①：这张卡不会被和相同攻击力的怪兽的战斗破坏。
-- ②：这张卡被破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽回到持有者手卡。
function c52824910.initial_effect(c)
	-- ①：这张卡不会被和相同攻击力的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c52824910.indes)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合，以场上1只怪兽为对象发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52824910,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c52824910.condition)
	e2:SetTarget(c52824910.target)
	e2:SetOperation(c52824910.operation)
	c:RegisterEffect(e2)
end
-- 作为“不会被战斗破坏”效果的判定函数：当这张卡将要被战斗破坏时，若战斗对象怪兽的当前攻击力等于这张卡的当前攻击力，则返回true使该战斗破坏无效。
function c52824910.indes(e,c)
	return c:IsAttack(e:GetHandler():GetAttack())
end
-- ②效果的发动条件判定：检查这张卡被送去墓地时，其送去墓地的原因中是否包含“破坏”，只有因破坏被送去墓地时此条件才成立。
function c52824910.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- ②效果的发动时处理：先进行取对象合法性判定（连锁处理时若被指定为对象的卡必须在主要怪兽区且能加入手卡）；若为发动确认阶段（chk==0）则直接允许发动；随后提示选择要返回手卡的卡，并从双方场上主要怪兽区选择1张能加入手卡的怪兽作为效果对象，同时向系统登记本次效果为“回手牌”的操作信息。
function c52824910.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向当前玩家显示“请选择要返回手牌的卡”的选择提示文字，用于卡片选择界面的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从双方场上主要怪兽区选择1张满足“能够加入手卡”条件的怪兽，并将其登记为当前连锁效果的对象（与效果建立关联）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次效果处理的操作信息登记为“回手牌”，对象为已选择的目标组g，数量为g的卡片数，以便后续处理相关时点或检测时使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果处理时的实际执行：取得效果对象卡，若该卡仍与效果保持关联（未离场或未失效），则将其返回持有者手卡。
function c52824910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果登记的第一个（也是唯一一个）对象卡，作为后续回手牌处理的目标。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以“效果”为原因，将这张对象怪兽卡返回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
