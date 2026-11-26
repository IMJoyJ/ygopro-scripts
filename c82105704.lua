--ピュアリィ・ハッピーメモリー
-- 效果：
-- ①：选场上1张卡，那张卡直到下个回合的结束时只有1次不会被效果破坏。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡持有作为超量素材中的「纯爱妖精快乐回忆」数量＋1次的攻击。
local s,id,o=GetID()
-- 初始化卡片效果：注册①赋予场上1张卡1次效破抗性并可选丢手卡特召1星「纯爱妖精」的速攻魔法效果，以及②作为超量素材赋予「纯爱妖精」超量怪兽多次对怪兽攻击的效果
function s.initial_effect(c)
	-- ①：选场上1张卡，那张卡直到下个回合的结束时只有1次不会被效果破坏。并且，可以再让以下效果适用。●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。●这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡持有作为超量素材中的「纯爱妖精快乐回忆」数量＋1次的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.xcon)
	e2:SetValue(s.xval)
	c:RegisterEffect(e2)
end
-- 发动前确认场上存在至少1张除发动中的此卡外的卡片
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在除自身外至少1张可选卡片
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end
-- 过滤卡组中1星且可特殊召唤的「纯爱妖精」怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：选场上1张卡赋予直到下回合结束时仅1次不被效果破坏的抗性，之后若条件满足可丢弃1张手卡从卡组特召1只1星「纯爱妖精」怪兽
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向己方发送从场上选择要赋予效破抗性的卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让己方从双方场上选择1张除与当前效果关联的自身以外的卡片
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	if not tc then return end
	-- 向双方展示被选中的场上卡片动画
	Duel.HintSelection(g)
	if not tc:IsImmuneToEffect(e) then
		-- 那张卡直到下个回合的结束时只有1次不会被效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetCountLimit(1)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 检查己方手卡是否存在至少1张可丢弃的卡
		if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
			-- 检查己方怪兽区是否至少有1个可用空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查己方卡组是否存在可特殊召唤的1星「纯爱妖精」怪兽
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问己方玩家是否适用丢弃1张手卡并从卡组特殊召唤1星「纯爱妖精」怪兽的后续效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
			-- 插入效果处理间断，使赋予抗性与后续丢弃特召视为不同时处理
			Duel.BreakEffect()
			-- 让己方选择1张手卡以效果丢弃并确认丢弃成功
			if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
				-- 向己方发送从卡组选择要特殊召唤的1星「纯爱妖精」怪兽的提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让己方从卡组选择1只1星「纯爱妖精」怪兽
				local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if sg:GetCount()>0 then
					-- 将选中的1星「纯爱妖精」怪兽以表侧表示特殊召唤到己方场上
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 次数盾破坏原因判定函数：仅当破坏原因包含效果破坏（REASON_EFFECT）时消耗防破次数
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- ②效果生效条件：持有此卡作为超量素材的怪兽须为「纯爱妖精」怪兽
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x18c)
end
-- 额外攻击次数计算函数：统计持有此卡的「纯爱妖精」超量怪兽当前超量素材中「纯爱妖精快乐回忆」的数量，决定追加的向怪兽攻击次数
function s.xval(e)
	local c=e:GetHandler()
	return c:GetOverlayGroup():FilterCount(Card.IsCode,nil,id)
end
