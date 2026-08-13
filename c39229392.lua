--オーバーレイ・スナイパー
-- 效果：
-- 这张卡不能特殊召唤。这张卡召唤成功时，变成守备表示。此外，自己场上有持有超量素材的超量怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上1只怪兽才能发动。选择的怪兽的攻击力下降自己场上的超量素材数量×500的数值。
function c39229392.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39229392,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c39229392.potg)
	e2:SetOperation(c39229392.poop)
	c:RegisterEffect(e2)
	-- 此外，自己场上有持有超量素材的超量怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上1只怪兽才能发动。选择的怪兽的攻击力下降自己场上的超量素材数量×500的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39229392,1))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c39229392.atkcon)
	-- 把墓地的这张卡从游戏中除外作为发动代价。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c39229392.atktg)
	e3:SetOperation(c39229392.atkop)
	c:RegisterEffect(e3)
end
-- 效果发动时确认这张卡为攻击表示，并登记将变更其表示形式的操作信息。
function c39229392.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 登记此次效果处理将包含改变表示形式（变成守备表示）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 处理效果：这张卡是表侧攻击表示且仍在场上时，将其变更为表侧守备表示。
function c39229392.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：表侧表示的超量怪兽，且拥有超量素材。
function c39229392.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 发动条件：自己场上有持有超量素材的超量怪兽存在。
function c39229392.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只持有超量素材的表侧表示超量怪兽。
	return Duel.IsExistingMatchingCard(c39229392.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 取对象效果的目标选择：选择对方场上的1只表侧表示怪兽作为对象；连锁时先校验对象是否合法，发动时确认存在合法对象后，让玩家选择。
function c39229392.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动时检查对方场上是否存在至少1只表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果：若对象仍表侧且与效果关联，则使对象怪兽攻击力下降自己场上的超量素材数量×500。
function c39229392.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力下降自己场上的超量素材数量×500的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 设置攻击力下降数值为自己场上的超量素材数量×500（以负值表示下降）。
		e1:SetValue(Duel.GetOverlayCount(tp,1,0)*-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
