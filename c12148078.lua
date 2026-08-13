--SRルーレット
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。掷1次骰子。等级合计直到变成和出现的数目相同为止从手卡·卡组把最多2只「疾行机人」怪兽效果无效特殊召唤。没能特殊召唤的场合，自己失去出现的数目×500基本分。
function c12148078.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡才能发动。掷1次骰子。等级合计直到变成和出现的数目相同为止从手卡·卡组把最多2只「疾行机人」怪兽效果无效特殊召唤。没能特殊召唤的场合，自己失去出现的数目×500基本分。
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
-- 代价筛选：用于检查手牌是否可丢弃，并且卡组·手牌中至少存在1只可特殊召唤的「疾行机人」怪兽（以等级6为最大点数进行初步检查）。
function c12148078.cfilter(c,e,tp)
	return c:IsDiscardable()
		-- 检查卡组·手牌中是否存在至少1只满足spfilter（「疾行机人」、等级≤6、可特殊召唤）的怪兽，确保丢弃代价后效果有处理对象。
		and Duel.IsExistingMatchingCard(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,6)
end
-- 特召候选过滤：筛选卡名含有「疾行机人」字段、等级不高于骰子点数、且可以被当前效果正常特殊召唤的怪兽。
function c12148078.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x2016) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价处理：先设置标签100标记代价已支付；询问时可发动则要求存在可丢弃手牌且存在可特召的疾行机人怪兽；随后提示并选择1张手牌丢弃，作为发动代价。
function c12148078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 代价检查（chk==0）：确认玩家手牌中是否存在可丢弃的卡，且卡组·手牌中有可供特殊召唤的「疾行机人」怪兽（以等级6为上限）。
	if chk==0 then return Duel.IsExistingMatchingCard(c12148078.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 向玩家显示“请选择要丢弃的手牌”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌中选择1张满足cfilter条件的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c12148078.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的手牌以代价和丢弃理由送入墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 发动时目标处理：若已支付代价则直接允许发动；否则检查是否存在可特召的疾行机人怪兽；通过后登记本效果包含掷骰子信息。
function c12148078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		-- 返回真当且仅当已支付过代价（res为true），或卡组·手牌中存在至少1只可特殊召唤的疾行机人怪兽（等级≤6的初步检查）。
		return res or Duel.IsExistingMatchingCard(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,6)
	end
	e:SetLabel(0)
	-- 登记操作信息，声明此效果在结算时包含投掷1次骰子，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 子组选择过滤：选择的怪兽等级合计必须等于骰子点数lv，用于选出等级合计恰好等于骰子点数的一组怪。
function c12148078.fselect(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
-- 效果结算：掷1次骰子；根据场上可用怪兽区数量限制（最多2只，若青眼精灵龙适用则最多1只）检索候选；选择等级合计等于骰子点数的疾行机人怪兽特殊召唤，并使其效果无效；没有特召成功时扣减骰子点数×500基本分。
function c12148078.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 投掷1次骰子，得到点数dc（1~6），作为后续选择等级合计目标及失败扣血数值。
	local dc=Duel.TossDice(tp,1)
	local res=false
	-- 获取玩家tp场上可用的主要怪兽区空格数，用于限制可特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if ft>2 then ft=2 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 检索手卡·卡组中所有满足spfilter（疾行机人、等级≤骰子点数、可特召）的怪兽，组成候选组。
		local g=Duel.GetMatchingGroup(c12148078.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp,dc)
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c12148078.fselect,false,1,ft,dc)
		if sg then
			-- 遍历已选中的特殊召唤怪兽组，逐个处理特殊召唤及无效效果。
			for tc in aux.Next(sg) do
				-- 将当前怪兽以表侧表示特殊召唤到tp场上，并检查其召唤条件/苏生限制。
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
			-- 结束连锁特殊召唤处理，正式完成多只怪兽的特殊召唤。
			Duel.SpecialSummonComplete()
			res=true
		end
	end
	if not res then
		-- 获取玩家tp当前的LP，用于后续扣除基本分。
		local lp=Duel.GetLP(tp)
		-- 将玩家LP减少骰子点数×500，作为没能特殊召唤场合失去的基本分。
		Duel.SetLP(tp,lp-dc*500)
	end
end
