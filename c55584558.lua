--ピュアリィ・デリシャスメモリー
-- 效果：
-- ①：选场上1只怪兽，那只怪兽直到下个回合的结束时不会被战斗破坏。并且，可以再让以下效果适用。
-- ●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
-- ②：持有这张卡作为素材中的「纯爱妖精」超量怪兽得到以下效果。
-- ●这张卡的攻击力·守备力上升这张卡的超量素材数量×300。
local s,id,o=GetID()
-- 初始化「纯爱妖精美味回忆」(55584558)：注册①赋予怪兽战破抗性及可选弃手卡特召1星「纯爱妖精」的发动效果，以及②作为「纯爱妖精」超量怪兽素材时提升攻守的效果
function s.initial_effect(c)
	-- ①：选场上1只怪兽，那只怪兽直到下个回合的结束时不会被战斗破坏。并且，可以再让以下效果适用。●选自己1张手卡丢弃，从卡组把1只1星「纯爱妖精」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_HANDES_SELF)
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
-- 效果①的Target函数：检测双方怪兽区是否存在至少1只怪兽
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认双方怪兽区存在至少1只可选择的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 过滤函数：筛选卡组中1星、属于「纯爱妖精」(0x18c)字段且可被特殊召唤的怪兽
function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsSetCard(0x18c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Operation函数：选场上1只怪兽赋予直到下个回合结束时的战破抗性，随后可选择丢弃1张手卡从卡组特召1只1星「纯爱妖精」怪兽
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向己方玩家发送选择场上要操作怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从双方场上不取对象地选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 手动为选中的怪兽显示被选定提示动画
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
		-- 检查己方手卡中是否存在至少1张可被丢弃的卡片
		if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
			-- 且检查己方主要怪兽区是否还有可用空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 且检查己方卡组中是否存在至少1只可特殊召唤的1星「纯爱妖精」怪兽
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问己方玩家是否要再适用弃手卡并从卡组特殊召唤的后续效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组特殊召唤？"
			-- 中断当前处理步骤，使后续丢弃手卡与卡组特召视为不同时处理
			Duel.BreakEffect()
			-- 让己方玩家选择1张手卡以效果丢弃并确认丢弃成功
			if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
				-- 向己方玩家发送选择要特殊召唤的1星「纯爱妖精」怪兽提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从己方卡组中选择1只可特殊召唤的1星「纯爱妖精」怪兽
				local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				if g:GetCount()>0 then
					-- 将选中的1星「纯爱妖精」怪兽以表侧表示特殊召唤到己方场上
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 超量素材附带效果②的Condition函数：检查持有这张卡作为超量素材的怪兽是否属于「纯爱妖精」(0x18c)字段
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x18c)
end
-- 超量素材附带效果②的Value函数：计算并返回该超量怪兽当前超量素材数量×300的攻守增益数值
function s.xval(e,c)
	return e:GetHandler():GetOverlayCount()*300
end
