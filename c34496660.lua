--超重武者ダイ－8
-- 效果：
-- 「超重武者 大八-8」的③的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ③：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己场上的表侧守备表示的这张卡变成攻击表示，从卡组把1只「超重武者装留」怪兽加入手卡。
function c34496660.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34496660,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c34496660.postg)
	e1:SetOperation(c34496660.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 「超重武者 大八-8」的③的效果1回合只能使用1次。③：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己场上的表侧守备表示的这张卡变成攻击表示，从卡组把1只「超重武者装留」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34496660,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,34496660)
	e4:SetCondition(c34496660.thcon)
	e4:SetTarget(c34496660.thtg)
	e4:SetOperation(c34496660.thop)
	c:RegisterEffect(e4)
end
-- ①效果的发动目标判定：在召唤成功的时点，若chk=0则返回true表示允许发动；并登记将这张卡作为改变表示形式的处理对象。
function c34496660.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将这张卡登记为效果处理时要变更表示形式的对象（CATEGORY_POSITION），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 处理①效果：取得效果拥有者这张卡c；若c仍与此效果关联（没有离场或失去对象），则变更c的表示形式。
function c34496660.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 变更表示形式：根据当前表示形式切换——表侧攻击表示变为表侧守备表示，其余表示形式变为表侧攻击表示（即实现“这张卡的表示形式变更”）。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- ③效果的发动条件：这张卡存在于我方场上且为表侧守备表示，并且自己墓地没有魔法·陷阱卡。
function c34496660.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
		-- 检查自己墓地不存在魔法·陷阱卡：若自己墓地存在至少1张魔法或陷阱卡则条件不成立（not 不存在）。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 检索过滤函数：选出卡名属于「超重武者装留」字段（0x109a）且能够加入手卡的怪兽，对应“从卡组把1只「超重武者装留」怪兽加入手卡”。
function c34496660.thfilter(c)
	return c:IsSetCard(0x109a) and c:IsAbleToHand()
end
-- ③目标判定与操作登记：发动时先检查卡组是否存在符合条件的「超重武者装留」怪兽；存在则登记从卡组将1张卡加入手卡的操作信息。
function c34496660.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：卡组中至少存在1张满足thfilter条件的「超重武者装留」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34496660.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果处理时将进行“从卡组把卡加入手卡”的操作（CATEGORY_TOHAND），对象不取对象，数量1，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理③效果：先尝试将这张卡从表侧守备表示变为表侧攻击表示；若成功，则从卡组选择1只「超重武者装留」怪兽加入手卡，并给对方确认。
function c34496660.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理保护判断：若这张卡与效果无关联、已不是表侧守备表示、或变更成攻击表示的操作失败（返回0），则终止本次效果处理，不进行检索。
	if not c:IsRelateToEffect(e) or not c:IsPosition(POS_FACEUP_DEFENSE) or Duel.ChangePosition(c,POS_FACEUP_ATTACK)==0 then return end
	-- 弹出选择提示：向玩家显示“请选择要加入手牌的卡”的选择框文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己卡组选出1张满足thfilter条件的「超重武者装留」怪兽（数量恰好1张）作为加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,c34496660.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡以效果原因送入其持有者的手卡（nil表示返回持有者手卡，实际就是tp的手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方的玩家（1-tp）确认，确保检索信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
