--暗黒界の軍神 シルバ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让对方选自身2张手卡用喜欢的顺序回到卡组下面。
function c32619583.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，再让对方选自身2张手卡用喜欢的顺序回到卡组下面。
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
-- spcon：记录这张卡在丢弃前的控制者，并判断它是否是从手牌因效果丢弃（REASON_EFFECT+REASON_DISCARD），用于验证“这张卡被效果从手卡丢弃去墓地”这一发动条件。
function c32619583.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- sptg：作为必发效果的发动时处理，无需选择对象，直接允许发动，并登记后续要进行的特殊召唤操作。
function c32619583.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果处理信息登记为对这张卡自身进行特殊召唤，数量为1，供系统进行发动合法性检查和时点关联。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- spop：效果处理时，先尝试将这张卡表侧攻击表示特殊召唤；若满足被对方效果丢弃且原控制者为当前发动者、对方手牌数大于1，则继续让对方选择自身2张手卡放回卡组底部。
function c32619583.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡仍然与效果关联且特殊召唤成功，只有特殊召唤成功后才继续执行后续的回卡组效果。
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0
		-- 判断丢弃效果来源于对方（rp==1-tp）、这张卡丢弃前的控制者为当前效果使用者，并且对方手牌数超过1张，满足这些条件才发动“对方选2张手卡回到卡组下面”的追加处理。
		and rp==1-tp and tp==e:GetLabel() and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>1 then
		-- 中断当前效果链，使后续的“选手卡回卡组”处理与特殊召唤不在同一时点处理，避免错误合并时点导致漏发或错发。
		Duel.BreakEffect()
		-- 向对方玩家显示选择提示“请选择要返回卡组的卡”，为接下来选择手卡做准备。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让对方从自身手卡中任意选择2张卡（不取对象、无条件限制），作为要放回卡组底部的卡片。
		local g=Duel.SelectMatchingCard(1-tp,aux.TRUE,tp,0,LOCATION_HAND,2,2,nil)
		-- 让对方面前选择的2张手卡，按对方自己决定的顺序放置到卡组最下面。
		aux.PlaceCardsOnDeckBottom(1-tp,g)
	end
end
