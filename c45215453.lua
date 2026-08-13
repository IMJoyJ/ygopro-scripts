--ヴァイロン・デルタ
-- 效果：
-- 调整＋调整以外的光属性怪兽1只以上
-- 这张卡表侧守备表示存在的场合，自己的结束阶段时可以从自己卡组选择1张装备魔法卡加入手卡。
function c45215453.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽作为调整，加上1只以上调整以外的光属性怪兽（aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT)）作为非调整素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- 对应效果原文：“调整＋调整以外的光属性怪兽1只以上。这张卡表侧守备表示存在的场合，自己的结束阶段时可以从自己卡组选择1张装备魔法卡加入手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45215453,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c45215453.thcon)
	e1:SetTarget(c45215453.thtg)
	e1:SetOperation(c45215453.thop)
	c:RegisterEffect(e1)
end
-- 发动条件函数：判定当前回合玩家是效果控制者tp，且效果持有者（这张卡）处于守备表示，满足时才可在结束阶段发动。
function c45215453.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家为tp，且这张卡为守备表示（对应原效果“表侧守备表示存在的场合”，在怪兽效果发动判定中即表侧守备）。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsDefensePos()
end
-- 过滤函数：用于筛选卡组中满足条件的卡——装备魔法且可以被加入手卡（不受“不能加入手卡”限制）。
function c45215453.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果目标设定函数：在发动时检查自己卡组是否存在至少1张符合条件的装备魔法卡，并设置操作信息为将1张卡从卡组加入手卡。
function c45215453.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若是在效果发动时点（chk==0），则检索自己卡组中是否存在至少1张满足c45215453.filter的装备魔法卡，没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c45215453.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告本次效果会将1张装备魔法卡从持有者的卡组加入手卡（目标在效果处理时选择，因此targets传nil），供连锁与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：先确认这张卡仍表侧守备表示且与发动效果保持关联；然后让tp选择1张符合条件的装备魔法卡，将其加入持有者手卡，并向对方展示。
function c45215453.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:IsAttackPos() or not c:IsRelateToEffect(e) then return end
	-- 给玩家tp显示“请选择要加入手牌的卡”的选择提示消息（HINT_SELECTMSG用于选择卡前的提示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己卡组选择1张满足c45215453.filter的卡（装备魔法且可加入手卡），选择结果存入组对象g。
	local g=Duel.SelectMatchingCard(tp,c45215453.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡g送去其持有者的手卡（player为nil表示回到持有者手卡），原因为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡g展示给对方玩家（1-tp）确认，符合检索类效果需让对方确认的规则。
		Duel.ConfirmCards(1-tp,g)
	end
end
