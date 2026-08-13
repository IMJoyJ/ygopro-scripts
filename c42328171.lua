--ゼンマイバット
-- 效果：
-- 自己的主要阶段时才能发动。把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，选择自己墓地存在的1只名字带有「发条」的怪兽加入手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c42328171.initial_effect(c)
	-- 自己的主要阶段时才能发动。把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，选择自己墓地存在的1只名字带有「发条」的怪兽加入手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42328171,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c42328171.thcon)
	e1:SetTarget(c42328171.thtg)
	e1:SetOperation(c42328171.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在自己场上表侧攻击表示存在。
function c42328171.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 检索墓地中满足条件的「发条」怪兽：卡名带有「发条」、是怪兽且能被加入手卡。
function c42328171.filter(c)
	return c:IsSetCard(0x58) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时从自己墓地选择1只符合条件的「发条」怪兽作为对象，并设置回手牌的操作信息；若不存在可选对象则不能发动。
function c42328171.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42328171.filter(chkc) end
	-- 效果发动时的合法性检查：自己墓地是否存在至少1只符合条件的「发条」怪兽且能成为对象。
	if chk==0 then return Duel.IsExistingTarget(c42328171.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示“请选择要加入手牌的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的「发条」怪兽，并将其设置为效果对象。
	local g=Duel.SelectTarget(tp,c42328171.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记当前连锁的操作信息：确定将把1张对象卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时：若此卡仍在自己场上且为表侧攻击表示、对象仍与此效果关联，则将此卡变更为表侧守备表示，并将对象怪兽加入持有者手卡，同时让对方确认。
function c42328171.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理阶段的对象卡（之前选择的那只「发条」怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 将此卡从表侧攻击表示变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		-- 将对象怪兽加入其持有者的手卡（回手牌），原因视为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的怪兽卡，以公开其信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
