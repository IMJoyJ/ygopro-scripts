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
	-- 设置①效果的发动条件：通过aux.dscon限制本效果在伤害步骤只能于伤害计算前发动。
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
-- ①效果的代价处理：支付'把自己场上1个超量素材取除'的代价，先检查再实际移除自己场上1个超量素材。
function c35394356.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）确认自己场上是否存在至少1个可去除的超量素材，若不存在则不能发动。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 实际支付代价：当前玩家tp从自己场上移除1个超量素材（REASON_COST）。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- ①效果的发动目标设定：选择对方场上1只表侧表示且攻击力不为0的怪兽为对象。
function c35394356.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果处理前再次校验对象时，判定选中的卡是否为对方场上表侧表示且攻击力不为0的怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 发动时检查对方场上是否存在1只表侧表示且攻击力不为0的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 给当前玩家显示'请选择表侧表示的卡'的选择提示，用于接下来的对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家从对方场上选择1只表侧表示且攻击力不为0的怪兽，并将其设为该效果的对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果发动后的处理：将对象怪兽的攻击力变为0，持续到回合结束。
function c35394356.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 那只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的代替除外条件判断：在超量怪兽发动取除素材的效果时，若满足本回合非送入墓地的回合、取除作为COST、发动效果者为超量怪兽且持有足够素材、该卡可作为代价除外、操作者为卡组所有者，则允许代替。
function c35394356.rcon(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果的部分条件：本回合非该卡送去墓地的回合，且被代替的取除操作是超量怪兽效果发动的COST（REASON_COST），并且该效果已被发动且属于超量怪兽。
	return aux.exccon(e) and bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and re:GetHandler():GetOverlayCount()>=ev-1 and e:GetHandler():IsAbleToRemoveAsCost() and ep==e:GetOwnerPlayer()
end
-- ②效果的代替除外操作：当条件满足时，将墓地的这张卡除外作为代替取除的超量素材。
function c35394356.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡以表侧表示除外，作为代替去除超量素材所需的COST。
	return Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
