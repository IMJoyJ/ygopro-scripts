--達磨落師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。这个效果在对方回合也能发动。
-- ②：自己场上的超量怪兽把超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
function c35394356.initial_effect(c)
	-- ①：把自己场上1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35394356,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_ATTACK+TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,35394356)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c35394356.atkcost)
	e1:SetTarget(c35394356.atktg)
	e1:SetOperation(c35394356.atkop)
	c:RegisterEffect(e1)
	-- ②：自己场上的超量怪兽把超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35394356,1))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35394357)
	e2:SetCondition(c35394356.rcon)
	e2:SetOperation(c35394356.rop)
	c:RegisterEffect(e2)
end
-- 支付效果代价：移除1个自身场上的超量素材
function c35394356.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除1个自身场上的超量素材作为代价
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 执行移除1个自身场上的超量素材作为代价
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 选择效果对象：对方场上的1只表侧表示怪兽
function c35394356.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断选择的目标是否符合要求：对方场上的表侧表示怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将目标怪兽的攻击力变为0
function c35394356.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 将目标怪兽的攻击力设置为0直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 代替去除超量素材的条件判断
function c35394356.rcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果发动的原因是否为代价且为超量怪兽的超量素材去除
	return aux.exccon(e) and bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and re:GetHandler():GetOverlayCount()>=ev-1 and e:GetHandler():IsAbleToRemoveAsCost() and ep==e:GetOwnerPlayer()
end
-- 代替去除超量素材的效果处理
function c35394356.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外作为代替去除的超量素材
	return Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
