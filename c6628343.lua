--開闢の騎士
-- 效果：
-- 「开辟之骑士」的①②的效果1回合各能使用1次。
-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。
-- ●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
-- ●这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续攻击。
-- ②：墓地的这张卡被除外的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
function c6628343.initial_effect(c)
	-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,6628343)
	e1:SetCondition(c6628343.mtcon)
	e1:SetOperation(c6628343.mtop)
	c:RegisterEffect(e1)
	-- ②：墓地的这张卡被除外的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,6628344)
	e2:SetCondition(c6628343.thcon)
	e2:SetTarget(c6628343.thtg)
	e2:SetOperation(c6628343.thop)
	c:RegisterEffect(e2)
end
-- 判定是否作为仪式召唤素材，且仪式召唤的怪兽是「混沌战士」怪兽，并且此卡之前不在超量素材中
function c6628343.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and eg:IsExists(Card.IsSetCard,1,nil,0x10cf)
		and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 为仪式召唤出的「混沌战士」怪兽赋予「除外对方场上怪兽」和「战斗破坏怪兽送去墓地时可再追加一次攻击」的效果，若该怪兽不是效果怪兽则为其添加效果怪兽类型
function c6628343.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x10cf)
	local rc=g:GetFirst()
	if not rc then return end
	-- ●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(6628343,0))  --"对方场上1只怪兽除外（开辟之骑士）"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c6628343.rmtg)
	e1:SetOperation(c6628343.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	-- ●这张卡战斗破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续攻击。
	local e2=Effect.CreateEffect(rc)
	e2:SetDescription(aux.Stringid(6628343,1))  --"再1次可以继续攻击（开辟之骑士）"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c6628343.atcon)
	e2:SetOperation(c6628343.atop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。/②：墓地的这张卡被除外的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(6628343,2))  --"「开辟之骑士」效果适用中"
end
-- 赋予效果1（除外对方怪兽）的发动准备：检查是否存在可除外的对方场上怪兽，并进行取对象和设置操作信息
function c6628343.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在至少1只可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1只可以被除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：除外选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 赋予效果1（除外对方怪兽）的效果处理：将选中的对象怪兽除外
function c6628343.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 赋予效果2（追加攻击）的发动条件：此卡战斗破坏对方怪兽送去墓地，且此卡可以继续攻击
function c6628343.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足“战斗破坏对方怪兽并送去墓地”的通用条件，且该怪兽当前可以进行追加攻击
	return aux.bdogcon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 赋予效果2（追加攻击）的效果处理：使该怪兽可以再进行1次攻击
function c6628343.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 允许该怪兽在本次战斗阶段中再进行1次攻击
	Duel.ChainAttack()
end
-- 效果2（检索仪式魔法）的发动条件：此卡被除外前存在于墓地
function c6628343.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤卡组中的仪式魔法卡
function c6628343.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- 效果2（检索仪式魔法）的发动准备：检查卡组中是否存在仪式魔法卡，并设置检索的操作信息
function c6628343.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以加入手牌的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6628343.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2（检索仪式魔法）的效果处理：从卡组选择1张仪式魔法卡加入手牌并给对方确认
function c6628343.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c6628343.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
