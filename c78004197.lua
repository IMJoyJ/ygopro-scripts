--暗黒界の武神 ゴルド
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，发动时可以以对方场上最多2张卡为对象。那个场合，再让以下效果适用。
-- ●作为对象的对方的卡破坏。
function c78004197.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，发动时可以以对方场上最多2张卡为对象。那个场合，再让以下效果适用。●作为对象的对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78004197,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c78004197.spcon)
	e1:SetTarget(c78004197.sptg)
	e1:SetOperation(c78004197.spop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：验证这张卡是否从手卡被效果丢弃送去墓地，并记录其原本的控制者。
function c78004197.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 效果的发动准备（Target）：处理特殊召唤的宣告，若被对方效果丢弃则可选择对方场上最多2张卡作为对象。
function c78004197.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 判定是否由对方的效果丢弃，且对方场上存在可作为对象的目标。
	if rp==1-tp and tp==e:GetLabel() and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否选择发动追加的破坏效果（选择对方场上的卡作为对象）。
		and Duel.SelectYesNo(tp,aux.Stringid(78004197,1)) then  --"是否要破坏对方场上的卡？"
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1到2张卡作为效果的对象。
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
		-- 设置连锁信息：包含破坏所选对象的操作。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
		-- 设置连锁信息：包含将自身特殊召唤的操作（选择破坏对象的情况）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
		e:SetLabel(1)
	else
		-- 设置连锁信息：包含将自身特殊召唤的操作（未选择破坏对象的情况）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
		e:SetProperty(0)
		e:SetLabel(0)
	end
end
-- 效果的处理（Operation）：将自身特殊召唤，若满足条件则在特殊召唤后将作为对象的卡破坏。
function c78004197.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自身成功特殊召唤，且发动时选择了破坏对象，则继续处理后续效果。
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 and e:GetLabel()==1 then
		-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行（造成错时点）。
		Duel.BreakEffect()
		-- 获取发动时选择的作为对象的卡片组。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if not g then return end
		local sg=g:Filter(Card.IsRelateToEffect,nil,e)
		-- 将作为对象的卡片中仍合法的卡破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
