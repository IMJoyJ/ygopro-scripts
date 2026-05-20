--インフェルノイド・ティエラ
-- 效果：
-- 「狱火机·拿玛」＋「狱火机·莉莉丝」＋「狱火机」怪兽1只以上
-- ①：这张卡融合召唤时才能发动。那些作为融合素材的怪兽种类的以下效果适用。
-- ●3种类以上：双方各自从自身的额外卡组把3张卡送去墓地。
-- ●5种类以上：双方各自从自身卡组上面把3张卡送去墓地。
-- ●8种类以上：双方各自让自身的除外状态的最多3张卡回到墓地。
-- ●10种类以上：有手卡的玩家把那些手卡全部送去墓地。
function c82734805.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤条件：「狱火机·拿玛」＋「狱火机·莉莉丝」＋「狱火机」怪兽1只以上
	aux.AddFusionProcCode2FunRep(c,14799437,23440231,aux.FilterBoolFunction(Card.IsFusionSetCard,0xbb),1,127,true,true)
	-- ①：这张卡融合召唤时才能发动。那些作为融合素材的怪兽种类的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82734805,0))  --"从额外卡组选3张卡送去墓地"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c82734805.con)
	e2:SetTarget(c82734805.tg)
	e2:SetOperation(c82734805.op)
	c:RegisterEffect(e2)
	-- 那些作为融合素材的怪兽种类的以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c82734805.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 检查融合素材的怪兽种类数量，并将其作为标签值保存在效果中
function c82734805.valcheck(e,c)
	local ct=e:GetHandler():GetMaterial():GetClassCount(Card.GetCode)
	e:GetLabelObject():SetLabel(ct)
end
-- 触发条件：此卡融合召唤成功时
function c82734805.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果发动时的目标确认与分类设置，根据融合素材的种类数量判断各阶段效果是否可以适用
function c82734805.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local con3,con5,con8,con10=nil,nil,nil,nil
	if ct>=3 then
		-- 检查自己额外卡组是否有至少3张卡可以送去墓地
		con3=Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,3,nil)
			-- 并且对方额外卡组是否有至少3张卡可以送去墓地
			and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,3,nil)
	end
	if ct>=5 then
		-- 检查双方玩家是否都能从自身卡组上面把3张卡送去墓地
		con5=Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.IsPlayerCanDiscardDeck(1-tp,3)
	end
	if ct>=8 then
		-- 检查自己除外状态的卡是否存在
		con8=Duel.IsExistingMatchingCard(nil,tp,LOCATION_REMOVED,0,1,nil)
			-- 并且对方除外状态的卡是否存在
			and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_REMOVED,1,nil)
	end
	if ct>=10 then
		-- 检查双方手牌总数是否大于0（即是否存在有手牌的玩家）
		con10=Duel.GetFieldGroupCount(tp,LOCATION_HAND,LOCATION_HAND)>0
	end
	if chk==0 then return con3 or con5 or con8 or con10 end
	local cat=0
	if ct>=3 or ct>=8 then cat=cat+CATEGORY_TOGRAVE end
	if ct>=5 then cat=cat+CATEGORY_DECKDES end
	if ct>=10 then cat=cat+CATEGORY_HANDES end
	e:SetCategory(cat)
end
-- 效果处理：根据融合素材的种类数量，依次适用对应的效果
function c82734805.op(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct>=3 then
		-- 获取自己额外卡组中可以送去墓地的卡片组
		local g1=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
		local sg1=nil
		if g1:GetCount()>=3 then
			-- 提示自己选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			sg1=g1:Select(tp,3,3,nil)
		else sg1=g1 end
		-- 获取对方额外卡组中可以送去墓地的卡片组
		local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
		local sg2=nil
		if g2:GetCount()>=3 then
			-- 提示对方选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			sg2=g2:Select(1-tp,3,3,nil)
		else sg2=g2 end
		sg1:Merge(sg2)
		if sg1:GetCount()>0 then
			-- 将双方选定的额外卡组的卡送去墓地
			Duel.SendtoGrave(sg1,REASON_EFFECT)
		end
	end
	if ct>=5 then
		-- 中断当前效果，使后续的卡组送墓处理不与前面的额外卡组送墓视为同时处理
		Duel.BreakEffect()
		-- 自己从卡组上面把3张卡送去墓地
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
		-- 对方从卡组上面把3张卡送去墓地
		Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	end
	if ct>=8 then
		-- 中断当前效果，使后续的除外卡回到墓地处理不与前面的卡组送墓视为同时处理
		Duel.BreakEffect()
		-- 提示自己选择要送去墓地的卡（此处用于选择除外状态的卡回到墓地）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 自己选择自身除外状态的最多3张卡
		local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_REMOVED,0,1,3,nil)
		-- 提示对方选择要送去墓地的卡（此处用于选择除外状态的卡回到墓地）
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 对方选择自身除外状态的最多3张卡
		local g2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_REMOVED,0,1,3,nil)
		g1:Merge(g2)
		if g1:GetCount()>0 then
			-- 将双方选定的除外状态的卡送回墓地
			Duel.SendtoGrave(g1,REASON_EFFECT+REASON_RETURN)
		end
	end
	if ct>=10 then
		-- 中断当前效果，使后续的手牌送墓处理不与前面的除外卡回墓视为同时处理
		Duel.BreakEffect()
		-- 获取双方玩家的所有手牌
		local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
		-- 将双方的所有手牌全部送去墓地
		Duel.SendtoGrave(g1,REASON_EFFECT)
	end
end
