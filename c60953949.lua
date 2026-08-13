--古代の機械箱
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡用抽卡以外的方法从卡组·墓地加入手卡的场合才能发动。「古代的机械箱」以外的1只攻击力或守备力是500的机械族·地属性怪兽从卡组加入手卡。
function c60953949.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡用抽卡以外的方法从卡组·墓地加入手卡的场合才能发动。「古代的机械箱」以外的1只攻击力或守备力是500的机械族·地属性怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60953949,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,60953949)
	e1:SetCondition(c60953949.thcon)
	e1:SetTarget(c60953949.thtg)
	e1:SetOperation(c60953949.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：这张卡加入手牌的原因不是抽卡，且加入手牌前位于卡组或墓地，满足“用抽卡以外的方法从卡组·墓地加入手卡的场合”条件。
function c60953949.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
		and e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义可检索的怪兽：攻击力或守备力为500、机械族、地属性、卡名不是「古代的机械箱」、且能够被加入手卡。
function c60953949.filter(c)
	return (c:IsAttack(500) or c:IsDefense(500)) and not c:IsCode(60953949)
		and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果的发动目标判定与操作信息设置：在发动阶段确认卡组中存在至少1只符合条件的怪兽，并登记本次效果为从卡组检索加入手卡。
function c60953949.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组中存在至少1只满足c60953949.filter条件的卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c60953949.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，标记本次效果包含CATEGORY_TOHAND（加入手卡）与CATEGORY_SEARCH（检索）类别，并预计从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张符合条件的机械族·地属性·攻击力或守备力500的怪兽加入手卡，并向对方展示。
function c60953949.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择加入手卡卡片的提示信息（“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己的卡组中选择1张满足c60953949.filter过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c60953949.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
