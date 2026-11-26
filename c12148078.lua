--SRルーレット
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。掷1次骰子。等级合计直到变成和出现的数目相同为止从手卡·卡组把最多2只「疾行机人」怪兽效果无效特殊召唤。没能特殊召唤的场合，自己失去出现的数目×500基本分。
function c12148078.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡才能发动。掷1次骰子。等级合计直到变成和出现的数目相同为止从手卡·卡组把最多2只「疾行机人」怪兽特殊召唤。没能特殊召唤的场合，自己失去出现的数目×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12148078+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c12148078.cost)
	e1:SetTarget(c12148078.target)
	e1:SetOperation(c12148078.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选可作为代价丢弃的手卡，且丢弃后卡组·手卡中仍存在等级6以下可特殊召唤的「疾行机人」怪兽
function c12148078.cfilter(c,e,tp)
	return c:IsDiscardable()
		-- 检查除该手卡外，己方卡组·手卡是否存在至少1只等级6以下可特召的「疾行机人」怪兽（确保骰子至少有理论可行目标）
		and Duel.IsExistingMatchingCard(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,6)
end
-- 过滤函数：筛选卡组或手卡中等级不高于lv且可被特殊召唤的「疾行机人」(0x2016)怪兽
function c12148078.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价函数：在检测阶段标记Label=100并检查手卡中是否有可丢弃的代价卡，处理时选择1张手卡丢弃至墓地
function c12148078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查手卡中是否存在除这张卡自身外满足代价过滤条件的可丢弃卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c12148078.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 向己方玩家发送选择要丢弃的手卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从己方手卡中选择1张满足条件的卡作为丢弃代价
	local g=Duel.SelectMatchingCard(tp,c12148078.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的手卡以代价丢弃的方式送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果Target函数：若已通过cost检查或手卡·卡组存在候选怪兽则允许发动，并设置掷1次骰子的操作信息
function c12148078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		-- 若经过了cost校验或当前手卡·卡组存在6星以下可特召的「疾行机人」怪兽则通过检测
		return res or Duel.IsExistingMatchingCard(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,6)
	end
	e:SetLabel(0)
	-- 设置己方掷1次骰子的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 子组过滤函数：检查所选怪兽组的等级总和是否恰好等于掷出的骰子点数lv
function c12148078.fselect(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 效果处理函数：掷1次骰子，根据可用格子数与上限从手卡·卡组特召最多2只等级和等于点数的「疾行机人」怪兽并无效其效果；未特召则失去点数×500基本分
function c12148078.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让己方玩家掷1次骰子并记录出现的点数dc
	local dc=Duel.TossDice(tp,1)
	local res=false
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if ft>2 then ft=2 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取己方卡组和手卡中所有等级不超过dc且可特殊召唤的「疾行机人」怪兽
		local g=Duel.GetMatchingGroup(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp,dc)
		-- 向己方玩家发送选择要特殊召唤的怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c12148078.fselect,false,1,ft,dc)
		if sg then
			-- 遍历选中的需要特殊召唤的「疾行机人」怪兽卡片组
			for tc in aux.Next(sg) do
				-- 以分步特殊召唤方式将当前怪兽表侧特殊召唤到己方场上
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 效果无效
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
			-- 统一完成本次分步特殊召唤流程并触发相关时点
			Duel.SpecialSummonComplete()
			res=true
		end
	end
	if not res then
		-- 获取己方玩家当前的基本分数值
		local lp=Duel.GetLP(tp)
		-- 在未能特殊召唤怪兽时，使己方失去骰子点数×500的基本分
		Duel.SetLP(tp,lp-dc*500)
	end
end
