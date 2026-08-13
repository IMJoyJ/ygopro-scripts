--セイクリッド・エスカ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以从自己卡组把1只名字带有「星圣」的怪兽加入手卡。
function c14759024.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，可以从自己卡组把1只名字带有「星圣」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14759024,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c14759024.tg)
	e1:SetOperation(c14759024.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e2)
	c14759024.star_knight_summon_effect=e1
end
-- 该过滤函数用于筛选卡组中满足“名字带有「星圣」的怪兽卡”且“可以被加入手卡”的卡片。
function c14759024.filter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 作为诱发效果的目标设定：在发动时检查自己卡组是否存在符合条件的星圣怪兽，并预先设置检索加入手卡的操作信息。
function c14759024.tg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 在发动条件检查阶段（chk==0），确认卡组中存在至少1只满足c14759024.filter条件的星圣怪兽，以保证效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c14759024.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置本次连锁的处理信息：将检索到的卡片加入持有者手卡（回手牌分类），用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：玩家从卡组选择1只符合条件的星圣怪兽加入手卡，且若选到则向对方展示。
function c14759024.op(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示文字“请选择要加入手牌的卡”，引导其进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选出1只满足c14759024.filter的星圣怪兽（处理时选择，不是发动时取对象）。
	local g=Duel.SelectMatchingCard(tp,c14759024.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因送去持有者的手卡（实际加入手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的那张卡，符合游戏规则中的公开信息确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
