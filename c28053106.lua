--サイバー・エッグ・エンジェル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1张「机械天使」魔法卡或者「祝福的教会-仪式教堂」加入手卡。
function c28053106.initial_effect(c)
	-- 将卡号95658967（祝福的教会-仪式教堂）登记到本卡上，表示本卡效果文本中提及了这张卡，用于相关卡名检索或判定。
	aux.AddCodeList(c,95658967)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1张「机械天使」魔法卡或者「祝福的教会-仪式教堂」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28053106,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,28053106)
	e1:SetTarget(c28053106.thtg)
	e1:SetOperation(c28053106.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义检索过滤函数：被选择的卡必须是「机械天使」魔法卡（字段0x124且为魔法卡类型）或卡号95658967（祝福的教会-仪式教堂），并且可以被加入手卡。
function c28053106.thfilter(c)
	return ((c:IsSetCard(0x124) and c:IsType(TYPE_SPELL)) or c:IsCode(95658967)) and c:IsAbleToHand()
end
-- 效果发动前的目标判定函数：在发动时确认是否存在可检索的卡，并设置本次效果的操作信息为从卡组将1张卡加入手卡。
function c28053106.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中是否存在满足检索条件的卡，只有存在时才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28053106.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的处理信息：效果分类为加入手卡（CATEGORY_TOHAND），预期将1张卡从卡组加入手牌，供其他效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：提示玩家选择要加入手牌的卡，从卡组选出1张符合条件的卡加入手牌，并让对方确认加入手牌的卡。
function c28053106.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动者显示“请选择要加入手牌的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从自己卡组中筛选1张满足c28053106.thfilter条件的卡，作为效果要加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c28053106.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入持有者的手卡，即完成加入手牌处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
