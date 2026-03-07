--暗黒界の軍神 シルバ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让对方选自身2张手卡用喜欢的顺序回到卡组下面。
function c32619583.initial_effect(c)
	-- 效果原文内容：①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让对方选自身2张手卡用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32619583,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c32619583.spcon)
	e1:SetTarget(c32619583.sptg)
	e1:SetOperation(c32619583.spop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断此卡是否从手卡被丢弃到墓地且是由对方的效果导致的
function c32619583.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 规则层面操作：设置效果发动时的处理信息，准备特殊召唤此卡
function c32619583.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置当前效果将要特殊召唤的卡片为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面操作：当满足条件时，执行特殊召唤并可能让对方将手牌放回卡组底
function c32619583.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查此卡是否还在场上（未被破坏或除外），并成功特殊召唤
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0
		-- 规则层面操作：确认是对方的效果导致丢弃，并且自己手牌数量大于1
		and rp==1-tp and tp==e:GetLabel() and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>1 then
		-- 规则层面操作：中断当前连锁处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 规则层面操作：提示对方选择2张手牌放回卡组底
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 规则层面操作：选择对方2张手牌作为目标
		local g=Duel.SelectMatchingCard(1-tp,aux.TRUE,tp,0,LOCATION_HAND,2,2,nil)
		-- 规则层面操作：将选中的2张手牌放回对方卡组底端
		aux.PlaceCardsOnDeckBottom(1-tp,g)
	end
end
