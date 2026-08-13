--スピードローダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己受到效果伤害时才能发动。这张卡从手卡特殊召唤。那之后，给与对方为和自己受到的伤害相同数值的伤害，自己基本分回复给与的伤害一半的数值。
-- ②：这张卡上级召唤成功时才能发动。从卡组把2只「弹丸」怪兽加入手卡（同名卡最多1张）。
function c12950294.initial_effect(c)
	-- ①：自己受到效果伤害时才能发动。这张卡从手卡特殊召唤。那之后，给与对方为和自己受到的伤害相同数值的伤害，自己基本分回复给与的伤害一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12950294,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCountLimit(1,12950294)
	e1:SetCondition(c12950294.spcon)
	e1:SetTarget(c12950294.sptg)
	e1:SetOperation(c12950294.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡上级召唤成功时才能发动。从卡组把2只「弹丸」怪兽加入手卡（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12950294,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,12950295)
	e2:SetCondition(c12950294.thcon)
	e2:SetTarget(c12950294.thtg)
	e2:SetOperation(c12950294.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己受到效果伤害（伤害来源为效果伤害）时才能发动。
function c12950294.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- ①效果发动时的合法性检查：自己主要怪兽区有空位，且这张卡能够特殊召唤。
function c12950294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：登记本次效果将造成的伤害，数值为 ev。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,ev)
	-- 设置操作信息：登记本次效果将回复自己基本分，数值为 ev 的一半向上取整。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(ev/2))
end
-- ①效果处理：这张卡从手卡特殊召唤，成功后给与对方与自己受到的伤害相同数值的伤害，然后自己回复那个伤害一半的数值。
function c12950294.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与本次效果关联，且特殊召唤成功后才继续后续伤害/回复处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使特殊召唤成功后的伤害/回复处理作为新的处理节点，以正确触发时点。
		Duel.BreakEffect()
		-- 给与对方与自己受到的效果伤害相同数值（ev）的伤害，val 记录实际造成的伤害值。
		local val=Duel.Damage(1-tp,ev,REASON_EFFECT)
		if val>0 then
			-- 自己回复实际造成的伤害 val 的一半（向上取整）。
			Duel.Recover(tp,math.ceil(val/2),REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡上级召唤成功时才能发动。
function c12950294.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 检索过滤器：从卡组中选出「弹丸」怪兽且能够加入手卡的卡。
function c12950294.thfilter(c)
	return c:IsSetCard(0x102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果发动时点：检查卡组中满足条件的「弹丸」怪兽的卡名种类不少于2，并设置检索2张卡加入手卡的操作信息。
function c12950294.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足条件的「弹丸」怪兽（不取对象）。
		local g=Duel.GetMatchingGroup(c12950294.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息：从卡组将2张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择2只「弹丸」怪兽加入手卡（同名卡最多1张），并向对方确认。
function c12950294.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取卡组中所有满足条件的「弹丸」怪兽。
	local g=Duel.GetMatchingGroup(c12950294.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 弹出选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选的「弹丸」怪兽中选择2张卡名不同的卡（同名卡最多1张）。
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的2张卡加入手卡（不指定玩家，默认加入持有者手卡）。
	Duel.SendtoHand(tg1,nil,REASON_EFFECT)
	-- 向对方玩家展示确认加入手卡的卡。
	Duel.ConfirmCards(1-tp,tg1)
end
