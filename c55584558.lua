--ピュアリィ・デリシャスメモリー
-- 效果：
-- ①：选场上1只怪兽，那只怪兽直到下个回合的结束时不会被战斗破坏。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●这张卡的攻击力·守备力上升这张卡的超量素材数量×300。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（魔法卡发动），以及②效果（作为超量素材时使超量怪兽上升攻击力和守备力）。
function s.initial_effect(c)
	-- ①：选场上1只怪兽，那只怪兽直到下个回合的结束时不会被战斗破坏。并且，可以再让以下效果适用。●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。●这张卡的攻击力·守备力上升这张卡的超量素材数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.xcon)
	e2:SetValue(s.xval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- ①效果的发动准备（Target）：检查场上是否存在至少1只怪兽。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上（双方怪兽区域）是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 过滤条件：卡组中等级为1且属于「纯爱妖精」系列、可以特殊召唤的怪兽。
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理（Operation）：使场上1只怪兽直到下个回合结束时不会被战斗破坏，之后可选择丢弃1张手卡并从卡组特殊召唤1只1星「纯爱妖精」怪兽。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 玩家选择场上（双方怪兽区域）的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 选中该怪兽并向双方玩家展示。
	Duel.HintSelection(g)
	if not tc:IsImmuneToEffect(e) then
		-- 那只怪兽直到下个回合的结束时不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 检查自己手卡中是否存在可以丢弃的卡。
		if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
			-- 检查自己的主要怪兽区域是否有空位。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在满足条件的1星「纯爱妖精」怪兽。
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否选择适用后续效果（丢弃手卡并特殊召唤）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
			-- 中断当前效果处理，使后续的丢弃手卡和特殊召唤处理与之前的战斗破坏抗性赋予不视为同时处理。
			Duel.BreakEffect()
			-- 玩家选择自己1张手卡丢弃，若成功丢弃则继续处理。
			if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
				-- 提示玩家选择要特殊召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从卡组中选择1只满足条件的1星「纯爱妖精」怪兽。
				local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if g:GetCount()>0 then
					-- 将选中的怪兽以表侧表示特殊召唤到自己的场上。
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 检查持有该素材的超量怪兽是否为「纯爱妖精」怪兽。
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x18c)
end
-- 计算攻击力/守备力上升的数值：该怪兽的超量素材数量乘以300。
function s.xval(e,c)
	return e:GetHandler():GetOverlayCount()*300
end
