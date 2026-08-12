--ペロペロケルペロス
-- 效果：
-- ①：这张卡在墓地存在，战斗或者对方的效果让自己受到伤害的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
function c69764158.initial_effect(c)
	-- ①：这张卡在墓地存在，战斗或者对方的效果让自己受到伤害的场合，把墓地的这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69764158,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c69764158.descon)
	-- 设置把墓地的这张卡除外作为发动的代价（Cost）
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c69764158.destg)
	e1:SetOperation(c69764158.desop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：自己受到伤害，且该伤害是由战斗或者对方的效果造成的
function c69764158.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (bit.band(r,REASON_BATTLE)~=0 or (bit.band(r,REASON_EFFECT)~=0 and rp==1-tp))
end
-- 效果发动时的目标选择与检测（Target阶段），确认场上是否存在可选择的对象，并进行取对象操作
function c69764158.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段（chk==0）检测双方场上是否存在至少1张可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家从双方场上选择1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表明该效果包含破坏分类，且破坏的目标是已选择的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段（Operation阶段），获取对象卡并将其破坏
function c69764158.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
