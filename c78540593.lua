--姫葵マリーナ
-- 效果：
-- 只要这张卡在场上表侧表示存在，这张卡以外的自己场上的植物族怪兽1只被战斗或者卡的效果破坏送去墓地的场合，可以选择对方场上1张卡破坏。
function c78540593.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，这张卡以外的自己场上的植物族怪兽1只被战斗或者卡的效果破坏送去墓地的场合，可以选择对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78540593,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c78540593.descon)
	e1:SetTarget(c78540593.destg)
	e1:SetOperation(c78540593.desop)
	c:RegisterEffect(e1)
end
-- 检查是否满足“这张卡以外的自己场上的植物族怪兽1只被战斗或者卡的效果破坏送去墓地”的发动条件
function c78540593.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsReason(REASON_DESTROY) and tc:IsReason(REASON_BATTLE+REASON_EFFECT)
		and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousControler(tp)
		and bit.band(tc:GetPreviousRaceOnField(),RACE_PLANT)~=0 and tc:IsRace(RACE_PLANT)
end
-- 效果的发动准备，选择对方场上1张卡作为破坏对象
function c78540593.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 在效果发动时，检查对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，声明将要破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理，若此卡在场上表侧表示存在且对象卡仍存在，则破坏该卡
function c78540593.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的破坏对象
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 以卡的效果破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
