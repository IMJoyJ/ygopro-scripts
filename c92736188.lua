--グレート・スピリット
-- 效果：
-- 这张卡1回合只有1次可以变成里侧守备表示。这张卡反转召唤成功时，选择场上1只地属性怪兽才能发动。选择的地属性怪兽的原本攻击力和原本守备力直到结束阶段时交换。
function c92736188.initial_effect(c)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92736188,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c92736188.target)
	e1:SetOperation(c92736188.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，选择场上1只地属性怪兽才能发动。选择的地属性怪兽的原本攻击力和原本守备力直到结束阶段时交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92736188,1))  --"攻守交换"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c92736188.adtg)
	e2:SetOperation(c92736188.adop)
	c:RegisterEffect(e2)
end
-- 变成里侧守备表示效果的发动条件与效果处理准备（包含1回合1次限制的Flag注册）
function c92736188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(92736188)==0 end
	c:RegisterFlagEffect(92736188,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表示该效果包含改变表示形式的操作，对象是自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的实际处理
function c92736188.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤场上表侧表示、地属性且有守备力的怪兽
function c92736188.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDefenseAbove(0)
end
-- 攻守交换效果的发动准备，确认并选择场上1只地属性怪兽作为对象
function c92736188.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c92736188.filter(chkc) end
	-- 检查场上是否存在可以作为效果对象的地属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c92736188.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的地属性怪兽作为效果对象
	Duel.SelectTarget(tp,c92736188.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 攻守交换效果的实际处理，将目标怪兽的原本攻击力和原本守备力直到结束阶段时交换
function c92736188.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_EARTH) then
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 选择的地属性怪兽的原本攻击力和原本守备力直到结束阶段时交换。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(bdef)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(batk)
		tc:RegisterEffect(e2)
	end
end
