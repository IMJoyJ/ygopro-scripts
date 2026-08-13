--マドルチェ・マジョレーヌ
-- 效果：
-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只「魔偶甜点」怪兽加入手卡。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c11868731.initial_effect(c)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11868731,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c11868731.retcon)
	e1:SetTarget(c11868731.rettg)
	e1:SetOperation(c11868731.retop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只「魔偶甜点」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11868731,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c11868731.shtg)
	e2:SetOperation(c11868731.shop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- ②的诱发条件判定：此卡是被对方破坏并送去墓地，且破坏前由自己控制时返回真。
function c11868731.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- ②的发动时处理：无额外条件，直接通过并设置送回卡组的操作信息。
function c11868731.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：将此卡返回卡组，处理对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果关联（未因离场等情况失效），则将其返回卡组并洗切。
function c11868731.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡返回持有者卡组并洗牌，移动原因为效果。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 检索过滤条件：卡为「魔偶甜点」字段的怪兽，且能被加入手卡。
function c11868731.filter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①的发动条件：自己卡组存在符合条件的「魔偶甜点」怪兽时才能发动；同时设置从卡组加入手卡的操作信息。
function c11868731.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：检查己方卡组中是否存在至少1张符合条件的「魔偶甜点」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c11868731.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：从卡组将1张卡加入手卡，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：提示选择，从卡组选1张符合条件的「魔偶甜点」怪兽加入手牌，并向对方展示。
function c11868731.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选出1张满足filter的卡。
	local g=Duel.SelectMatchingCard(tp,c11868731.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，移动原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
