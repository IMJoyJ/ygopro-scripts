--ディメンション・ゲート
-- 效果：
-- 这张卡的发动时，选择自己场上1只怪兽表侧表示从游戏中除外。此外，对方怪兽的直接攻击宣言时，可以把场上表侧表示存在的这张卡送去墓地。这张卡被送去墓地的场合，可以把这张卡的效果除外的怪兽特殊召唤。
function c44046281.initial_effect(c)
	-- 这张卡的发动时，选择自己场上1只怪兽表侧表示从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c44046281.target)
	e1:SetOperation(c44046281.operation)
	c:RegisterEffect(e1)
	-- 此外，对方怪兽的直接攻击宣言时，可以把场上表侧表示存在的这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44046281,0))  --"送去墓地"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c44046281.tgcon)
	e2:SetTarget(c44046281.tgtg)
	e2:SetOperation(c44046281.tgop)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地的场合，可以把这张卡的效果除外的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44046281,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c44046281.spcon)
	e2:SetTarget(c44046281.sptg)
	e2:SetOperation(c44046281.spop)
	c:RegisterEffect(e2)
end
-- 第一个效果的目标处理函数：确认自己场上存在可除外的怪兽，提示玩家选择1只作为对象，并登记除外操作信息。
function c44046281.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToRemove() end
	-- 发动合法性检查：chk==0 时，确认自己场上存在至少1只可以成为效果对象且能够被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示让玩家选择要除外的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让操作玩家从自己场上选择1只可除外的怪兽，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记将所选对象怪兽除外这一操作信息，供连锁判定和效果互动使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 第一个效果的解决：确认卡和对象仍与效果关联后，将对象怪兽表侧除外；成功除外且在除外区时，用此卡记录该怪兽（永续对象）。
function c44046281.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的目标卡，即发动时选中的那只怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断此卡与对象仍与效果关联，然后以表侧表示将对象怪兽除外，并确认除外成功且对象位于除外区。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
		c:SetCardTarget(tc)
	end
end
-- 第二个效果的发动条件：仅在对方怪兽直接攻击宣言时满足（攻击者为对方怪兽且无攻击目标）。
function c44046281.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽由对方控制（攻击者不是自己），且攻击目标为空，即直接攻击。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 第二个效果的发动时目标处理：该效果不取对象，发动合法时只需登记把此卡自身送去墓地的操作信息。
function c44046281.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记效果处理时把此卡自身送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 第二个效果的解决：若此卡仍与当前效果关联，则将其自身送去墓地。
function c44046281.tgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将次元之门自身以效果原因送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
-- 第三个效果的发动条件：检查此卡是否存在通过自身效果记录的被除外怪兽，且此卡已在墓地；若满足，则将那只怪兽存入效果标签并允许发动。
function c44046281.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and e:GetHandler():IsLocation(LOCATION_GRAVE) then
		e:SetLabelObject(tc)
		return true
	end
	return false
end
-- 特殊召唤效果的目标处理：取出效果标签中记录的被除外的怪兽，并在发动时检查自己场上是否有空位以及该怪兽能否被特殊召唤。
function c44046281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 在效果发动时检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将待特殊召唤的被除外的怪兽登记为当前连锁的对象，使其与效果关联，后续可通过 GetFirstTarget 取得。
	Duel.SetTargetCard(tc)
	-- 登记本次效果处理时特殊召唤 tc 的操作信息（分类为特殊召唤，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 特殊召唤效果的解决：取得之前登记的目标怪兽，确认其仍与效果关联后，将其以表侧表示特殊召唤到自己场上。
function c44046281.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的目标怪兽，即要特殊召唤的被除外的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将被除外的怪兽以表侧表示特殊召唤到 tp 的场上，按规则检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
