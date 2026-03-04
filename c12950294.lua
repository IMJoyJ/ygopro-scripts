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
-- 效果发动条件判断：伤害来源为自己的效果伤害
function c12950294.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 效果发动时的处理：判断是否满足特殊召唤条件
function c12950294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置给予对方伤害的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,ev)
	-- 设置自己回复LP的处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(ev/2))
end
-- 效果发动的处理函数
function c12950294.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否还在场上并成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，避免时点错乱
		Duel.BreakEffect()
		-- 给对方造成与自己受到的伤害相同的伤害
		local val=Duel.Damage(1-tp,ev,REASON_EFFECT)
		if val>0 then
			-- 自己回复受到伤害的一半数值
			Duel.Recover(tp,math.ceil(val/2),REASON_EFFECT)
		end
	end
end
-- 上级召唤成功时的发动条件判断
function c12950294.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 检索卡组中符合条件的「弹丸」怪兽
function c12950294.thfilter(c)
	return c:IsSetCard(0x102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 上级召唤效果发动时的处理：判断是否满足检索条件
function c12950294.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 从卡组中检索符合条件的怪兽
		local g=Duel.GetMatchingGroup(c12950294.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置将2只怪兽加入手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 上级召唤效果发动的处理函数
function c12950294.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索符合条件的怪兽
	local g=Duel.GetMatchingGroup(c12950294.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择2只卡名不同的怪兽
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的怪兽加入手牌
	Duel.SendtoHand(tg1,nil,REASON_EFFECT)
	-- 向对方确认加入手牌的怪兽
	Duel.ConfirmCards(1-tp,tg1)
end
