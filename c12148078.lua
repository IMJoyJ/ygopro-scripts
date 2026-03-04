--SRルーレット
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。掷1次骰子。等级合计直到变成和出现的数目相同为止从手卡·卡组把最多2只「疾行机人」怪兽效果无效特殊召唤。没能特殊召唤的场合，自己失去出现的数目×500基本分。
function c12148078.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。掷1次骰子。等级合计直到变成和出现的数目相同为止从手卡·卡组把最多2只「疾行机人」怪兽效果无效特殊召唤。没能特殊召唤的场合，自己失去出现的数目×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12148078+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c12148078.cost)
	e1:SetTarget(c12148078.target)
	e1:SetOperation(c12148078.activate)
	c:RegisterEffect(e1)
end
-- 检查手牌中是否存在可以丢弃且满足特殊召唤条件的卡片
function c12148078.cfilter(c,e,tp)
	return c:IsDiscardable()
		-- 同时检查卡组或手牌中是否存在满足等级条件的「疾行机人」怪兽
		and Duel.IsExistingMatchingCard(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,6)
end
-- 筛选满足条件的「疾行机人」怪兽，等级不超过指定值且可特殊召唤
function c12148078.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 支付发动费用：丢弃1张手牌
function c12148078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 判断是否满足支付费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c12148078.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择1张符合条件的手牌进行丢弃
	local g=Duel.SelectMatchingCard(tp,c12148078.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的手牌送入墓地作为发动费用
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 设置效果的发动目标
function c12148078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		-- 判断是否满足发动条件，包括是否已支付费用或卡组/手牌中存在符合条件的怪兽
		return res or Duel.IsExistingMatchingCard(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,6)
	end
	e:SetLabel(0)
	-- 设置操作信息，提示将进行一次骰子投掷
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 筛选满足等级总和等于骰子点数的怪兽组合
function c12148078.fselect(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 执行效果的处理流程
function c12148078.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 投掷一次骰子，获取点数
	local dc=Duel.TossDice(tp,1)
	local res=false
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if ft>2 then ft=2 end
		-- 若玩家受到效果影响，则只能召唤1只怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取卡组和手牌中所有满足条件的「疾行机人」怪兽
		local g=Duel.GetMatchingGroup(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp,dc)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:SelectSubGroup(tp,c12148078.fselect,false,1,ft,dc)
		if sg then
			-- 遍历选中的怪兽组
			for tc in aux.Next(sg) do
				-- 将当前怪兽特殊召唤
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 使该怪兽效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				tc:RegisterEffect(e2)
			end
			-- 完成所有特殊召唤步骤
			Duel.SpecialSummonComplete()
			res=true
		end
	end
	if not res then
		-- 获取当前玩家的基本分
		local lp=Duel.GetLP(tp)
		-- 扣除相应点数的基本分
		Duel.SetLP(tp,lp-dc*500)
	end
end
