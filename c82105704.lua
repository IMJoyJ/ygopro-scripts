--ピュアリィ・ハッピーメモリー
-- 效果：
-- ①：选场上1张卡，那张卡直到下个回合的结束时只有1次不会被效果破坏。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡持有作为超量素材中的「纯爱妖精快乐回忆」数量＋1次的攻击。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：选场上1张卡，那张卡直到下个回合的结束时只有1次不会被效果破坏。并且，可以再让以下效果适用。●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_HANDES)
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
-- 效果①的发动准备与合法性检查函数
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查场上是否存在至少1张除这张卡以外的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end
-- 过滤卡组中等级1且可以特殊召唤的「纯爱妖精」怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理函数
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 玩家选择场上1张除这张卡以外的卡片
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	if not tc then return end
	-- 为选择的卡片显示选中动画效果
	Duel.HintSelection(g)
	if not tc:IsImmuneToEffect(e) then
		-- 那张卡直到下个回合的结束时只有1次不会被效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetCountLimit(1)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 检查玩家手卡中是否存在可以丢弃的卡
		if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
			-- 检查玩家的主要怪兽区域是否有空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在满足条件的等级1「纯爱妖精」怪兽
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否选择适用后续效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
			-- 中断当前效果处理，使后续处理不与前面视为同时进行
			Duel.BreakEffect()
			-- 玩家选择并丢弃1张手卡，若成功则继续处理
			if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 玩家从卡组选择1只满足条件的等级1「纯爱妖精」怪兽
				local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if sg:GetCount()>0 then
					-- 将选择的怪兽以表侧表示特殊召唤到场上
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 设定不会被破坏的类型为效果破坏
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检查持有该素材的超量怪兽是否为「纯爱妖精」怪兽
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x18c)
end
-- 计算该超量怪兽持有的超量素材中「纯爱妖精快乐回忆」的数量
function s.xval(e)
	local c=e:GetHandler()
	return c:GetOverlayGroup():FilterCount(Card.IsCode,nil,id)
end
