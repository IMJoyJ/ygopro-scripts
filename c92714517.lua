--ビッグウェルカム・ラビュリンス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·卡组·墓地把1只「拉比林斯迷宫」怪兽特殊召唤。那之后，自己场上1只怪兽回到手卡。
-- ②：把墓地的这张卡除外，以自己场上1只恶魔族怪兽为对象才能发动（自己场上有8星以上的恶魔族怪兽存在的场合，也能作为代替以对方场上1张卡为对象）。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上发动）和②效果（墓地发动）。
function s.initial_effect(c)
	-- ①：从自己的手卡·卡组·墓地把1只「拉比林斯迷宫」怪兽特殊召唤。那之后，自己场上1只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只恶魔族怪兽为对象才能发动（自己场上有8星以上的恶魔族怪兽存在的场合，也能作为代替以对方场上1张卡为对象）。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置墓地效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索手卡、卡组、墓地中可以特殊召唤的「拉比林斯迷宫」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检测（检查怪兽区域空位及是否存在可特召的怪兽）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只可以特殊召唤的「拉比林斯迷宫」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 设置连锁处理中的操作信息：将自己场上的1只怪兽送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
-- ①效果的实际处理函数（特殊召唤怪兽，之后选择场上1只怪兽回到手卡，并处理白银姬等卡的追加破坏效果）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=0
	-- 检查自己场上是否有可用的怪兽区域空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡、卡组、墓地选择1只满足条件的「拉比林斯迷宫」怪兽（受王家长眠之谷影响）。
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		-- 如果成功将选择的怪兽以表侧表示特殊召唤。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 提示玩家选择要返回手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 让玩家选择自己场上1只可以回到手牌的怪兽。
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
			-- 闪烁显示被选择返回手牌的怪兽。
			Duel.HintSelection(rg)
			-- 中断当前效果处理，使后续的“回到手卡”与前面的“特殊召唤”不视为同时处理。
			Duel.BreakEffect()
			-- 将选择的怪兽送回持有者手卡，并记录成功回手的数量。
			res=Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
	-- 处理「拉比林斯迷宫」相关卡片（如白银姬等）在通常陷阱发动时的追加破坏效果。
	aux.LabrynthDestroyOp(e,tp,res)
end
-- 过滤函数：检查场上是否存在表侧表示的8星以上的恶魔族怪兽。
function s.checkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_FIEND)
end
-- 过滤函数：检查是否是可以回到手牌的卡（自己场上的恶魔族怪兽，或者在满足替代条件时对方场上的任意卡）。
function s.thfilter(c,tp,check)
	return c:IsAbleToHand() and (c:IsControler(tp) and c:IsFaceup() and c:IsRace(RACE_FIEND)
		or check and c:IsControler(1-tp))
end
-- ②效果的发动准备与对象选择（根据场上是否有8星以上恶魔族怪兽来决定是否可以取对方场上的卡为对象）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在8星以上的恶魔族怪兽。
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsOnField() and s.thfilter(chkc,tp,check) end
	-- 检查场上是否存在符合条件的、可以作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,1,nil,tp,check) end
	-- 提示玩家选择要返回手牌的对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择1张符合条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,1,1,nil,tp,check)
	-- 设置连锁处理中的操作信息：将选中的对象卡送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的实际处理函数（将作为对象的卡送回手卡）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
