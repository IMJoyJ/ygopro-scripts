--捕食植物キメラフレシア
-- 效果：
-- 「捕食植物」怪兽＋暗属性怪兽
-- ①：1回合1次，以持有这张卡的等级以下的等级的场上1只怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡和对方的表侧表示怪兽进行战斗的攻击宣言时才能发动。直到回合结束时，那只对方怪兽的攻击力下降1000，这张卡的攻击力上升1000。
-- ③：这张卡被送去墓地的场合，下次的准备阶段才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c25586143.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「捕食植物」怪兽和暗属性怪兽各1只作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- ①：1回合1次，以持有这张卡的等级以下的等级的场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25586143,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25586143.rmtg)
	e1:SetOperation(c25586143.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方的表侧表示怪兽进行战斗的攻击宣言时才能发动。直到回合结束时，那只对方怪兽的攻击力下降1000，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25586143,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c25586143.atkcon)
	e2:SetTarget(c25586143.atktg)
	e2:SetOperation(c25586143.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，下次的准备阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c25586143.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，下次的准备阶段才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25586143,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(c25586143.thcon)
	e4:SetTarget(c25586143.thtg)
	e4:SetOperation(c25586143.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：怪兽为表侧表示、等级不高于这张卡的等级，且可以被除外。
function c25586143.rmfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv) and c:IsAbleToRemove()
end
-- ①效果的发动条件与取对象处理：确认是否有可选择的怪兽；提示选择后，从双方场上选择1只满足条件的表侧表示怪兽作为对象，并设置除外操作信息。
function c25586143.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25586143.rmfilter(chkc,c:GetLevel()) end
	-- 判定场上是否存在至少1只满足条件的表侧表示怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c25586143.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetLevel()) end
	-- 向当前玩家显示选择提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的表侧表示怪兽作为效果对象，并建立取对象关系。
	local g=Duel.SelectTarget(tp,c25586143.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetLevel())
	-- 设置本连锁的除外操作信息：将对象卡除外，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理时，若对象卡仍与效果关联，则将其表侧表示除外。
function c25586143.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡与对方表侧表示怪兽进行攻击宣言时，记录该战斗对象并判定其为表侧表示。
function c25586143.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup()
end
-- 效果发动时，让战斗对象与本效果建立关联，以便处理时确认目标仍相关。
function c25586143.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():CreateEffectRelation(e)
end
-- ②效果处理：若对象怪兽仍相关、表侧表示且在对方场上且不免疫此效果，则使其攻击力下降1000；若本卡仍相关且表侧表示，则自身攻击力上升1000。
function c25586143.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
		-- 那只对方怪兽的攻击力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() and not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 这张卡的攻击力上升1000。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(1000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
-- ③效果的触发登记：这张卡被送去墓地时记录标记，若在准备阶段送去则标记持续到下个准备阶段并记录当前回合数，否则标记在下次准备阶段重置，以保证“下次准备阶段”才可发动。
function c25586143.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡被送去墓地时是否正处于准备阶段。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 为这张卡设置持续到准备阶段的标记：若在准备阶段送去则持续2次准备阶段并记录当前回合数，否则持续1次准备阶段。
		e:GetHandler():RegisterFlagEffect(25586143,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(25586143,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1,0)
	end
end
-- ③效果的发动条件：检查标记是否存在且已到达“下次准备阶段”（标记回合数与当前回合数不同）。
function c25586143.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(25586143)
	-- 返回真表示已经过到下一次准备阶段，允许发动检索效果。
	return tid and tid~=Duel.GetTurnCount()
end
-- 过滤条件：卡名含有「融合」字段的魔法卡，且能够加入手牌。
function c25586143.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ③效果发动时，检查卡组中是否存在符合条件的「融合」魔法卡，并设置检索加入手牌的操作信息。
function c25586143.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在至少1张可检索的「融合」魔法卡，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25586143.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的检索操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「融合」魔法卡加入手牌，并向对方展示确认。
function c25586143.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「融合」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c25586143.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌，原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次检索加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
