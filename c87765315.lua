--真竜の目覚め
-- 效果：
-- ①：「龙魔王」怪兽以及除灵摆怪兽以外的「龙剑士」怪兽在场上存在的场合才能发动。双方场上的卡全部回到持有者卡组。那之后，可以从卡组把1只「龙剑士」怪兽或者「龙魔王」怪兽无视召唤条件特殊召唤。
function c87765315.initial_effect(c)
	-- ①：「龙魔王」怪兽以及除灵摆怪兽以外的「龙剑士」怪兽在场上存在的场合才能发动。双方场上的卡全部回到持有者卡组。那之后，可以从卡组把1只「龙剑士」怪兽或者「龙魔王」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c87765315.condition)
	e1:SetTarget(c87765315.target)
	e1:SetOperation(c87765315.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：检查场上怪兽是否为表侧表示的「龙魔王」怪兽
function c87765315.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xda)
end
-- 筛选条件：检查场上怪兽是否为表侧表示、且灵摆怪兽以外的「龙剑士」怪兽
function c87765315.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xc7) and not c:IsType(TYPE_PENDULUM)
end
-- 筛选条件：检查卡组中的卡片是否为「龙魔王」或「龙剑士」怪兽，且能无视召唤条件特殊召唤
function c87765315.filter3(c,e,tp)
	return c:IsSetCard(0xda,0xc7) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动条件检查：确认双方场上同时存在「龙魔王」怪兽与非灵摆怪兽的「龙剑士」怪兽
function c87765315.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方怪兽区是否存在表侧表示的「龙魔王」怪兽
	return Duel.IsExistingMatchingCard(c87765315.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查双方怪兽区是否存在表侧表示且非灵摆怪兽的「龙剑士」怪兽
		and Duel.IsExistingMatchingCard(c87765315.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 发动检测与连锁信息设置：确认双方场上存在可回到卡组的卡，获取全部可回卡组的卡并登记返回卡组操作信息
function c87765315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认双方场上存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上所有可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 登记连锁的返回卡组操作信息，预计将双方场上全部可回卡组的卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理流程：将双方场上的卡全部返回持有者卡组并洗牌；若至少1张成功回卡组且己方怪兽区有空位，则可选从卡组无视召唤条件特召1只「龙剑士」或「龙魔王」怪兽
function c87765315.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上当前所有可回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果将双方场上的卡全部返回原持有者卡组并洗牌，确认至少有1张卡操作成功
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 检查己方主要怪兽区是否存在可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组中是否存在可无视召唤条件特殊召唤的「龙剑士」或「龙魔王」怪兽
		and Duel.IsExistingMatchingCard(c87765315.filter3,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问己方是否要从卡组把怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(87765315,0)) then  --"是否要把怪兽特殊召唤？"
		-- 中断效果处理，使后续的特殊召唤与前面的返回卡组视为不同时处理
		Duel.BreakEffect()
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从己方卡组选择1只「龙剑士」或「龙魔王」怪兽
		local g=Duel.SelectMatchingCard(tp,c87765315.filter3,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将所选怪兽以表侧表示、无视召唤条件特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
