--クリスタルクリアウィング・シンクロ・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的「幻透翼」怪兽1只
-- ①：1回合1次，对方把怪兽的效果发动时才能发动。这张卡直到回合结束时攻击力上升那只对方怪兽的原本攻击力数值，不受对方发动的怪兽的效果影响。
-- ②：1回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效并破坏。
-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从卡组把1只风属性怪兽加入手卡。
function c59765225.initial_effect(c)
	-- 设置同调召唤的手续：同调怪兽调整+1只调整以外的「幻透翼」怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSetCard,0xff),1,1)
	c:EnableReviveLimit()
	-- ①：1回合1次，对方把怪兽的效果发动时才能发动。这张卡直到回合结束时攻击力上升那只对方怪兽的原本攻击力数值，不受对方发动的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59765225,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c59765225.imcon)
	e1:SetOperation(c59765225.imop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59765225,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c59765225.discon)
	e2:SetTarget(c59765225.distg)
	e2:SetOperation(c59765225.disop)
	c:RegisterEffect(e2)
	-- ③：同调召唤的这张卡被对方送去墓地的场合才能发动。从卡组把1只风属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59765225,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c59765225.thcon)
	e3:SetTarget(c59765225.thtg)
	e3:SetOperation(c59765225.thop)
	c:RegisterEffect(e3)
end
c59765225.material_type=TYPE_SYNCHRO
-- 效果①的发动条件：对方把怪兽的效果发动时
function c59765225.imcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果①的效果处理：使这张卡的攻击力上升对方怪兽的原本攻击力数值，并获得不受对方发动的怪兽效果影响的抗性
function c59765225.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=0
		if rc:IsRelateToEffect(re) and (rc:IsFaceup() or not rc:IsLocation(LOCATION_MZONE)) then
			if rc:IsControler(1-tp) then
				atk=rc:GetBaseAttack()
			end
		else
			atk=rc:GetTextAttack()
		end
		if atk>0 then
			-- 这张卡直到回合结束时攻击力上升那只对方怪兽的原本攻击力数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
		-- 不受对方发动的怪兽的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(59765225,3))  --"不受对方发动的怪兽的效果影响"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(c59765225.efilter)
		c:RegisterEffect(e2)
	end
end
-- 免疫效果的过滤条件：对方发动的怪兽的效果
function c59765225.efilter(e,te)
	return te:IsActivated() and te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 效果②的发动条件：这张卡不在战斗破坏状态，且魔法·陷阱卡的效果发动时，并且该发动可以被无效
function c59765225.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查发动的效果是否为魔法·陷阱卡的效果，且该发动是否可以被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 效果②的靶向处理：设置无效发动与破坏的操作信息
function c59765225.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为“破坏该卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的效果处理：使发动无效并破坏
function c59765225.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果③的发动条件：同调召唤的这张卡在己方场上被对方送去墓地
function c59765225.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 检索卡片的过滤条件：卡组中的风属性怪兽
function c59765225.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- 效果③的靶向处理：确认卡组中存在可检索的风属性怪兽，并设置加入手卡的操作信息
function c59765225.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在至少1只满足条件的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59765225.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组把1只风属性怪兽加入手卡
function c59765225.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c59765225.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
