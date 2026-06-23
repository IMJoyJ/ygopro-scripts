--オーバーレイ・スナイパー
-- 效果：
-- 这张卡不能特殊召唤。这张卡召唤成功时，变成守备表示。此外，自己场上有持有超量素材的超量怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上1只怪兽才能发动。选择的怪兽的攻击力下降自己场上的超量素材数量×500的数值。
function c39229392.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，变成守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39229392,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c39229392.potg)
	e2:SetOperation(c39229392.poop)
	c:RegisterEffect(e2)
	-- 自己场上有持有超量素材的超量怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上1只怪兽才能发动。选择的怪兽的攻击力下降自己场上的超量素材数量×500的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39229392,1))  --"攻击下降"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c39229392.atkcon)
	-- 将此卡从游戏中除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c39229392.atktg)
	e3:SetOperation(c39229392.atkop)
	c:RegisterEffect(e3)
end
-- 判断是否能发动效果，检查此卡是否处于攻击表示
function c39229392.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置连锁操作信息，指定将此卡变为守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡变为守备表示
function c39229392.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
		-- 将此卡变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数，用于判断场上是否存在表侧表示的超量怪兽且有超量素材
function c39229392.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 判断是否满足发动条件，检查自己场上是否存在表侧表示的超量怪兽且有超量素材
function c39229392.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的超量怪兽
	return Duel.IsExistingMatchingCard(c39229392.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果目标选择函数，选择对方场上的1只表侧表示怪兽
function c39229392.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否能选择目标，检查对方场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，对目标怪兽造成攻击力下降效果
function c39229392.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽添加攻击力下降效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 设置攻击力下降值为场上超量素材数量乘以-500
		e1:SetValue(Duel.GetOverlayCount(tp,1,0)*-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
