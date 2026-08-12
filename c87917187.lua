--暗黒の召喚神
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡·卡组无视召唤条件特殊召唤。这个回合，自己怪兽不能攻击。
-- ②：把墓地的这张卡除外才能发动。从卡组把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只加入手卡。
function c87917187.initial_effect(c)
	-- 注册该卡在卡组中记载了「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」的卡名
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡·卡组无视召唤条件特殊召唤。这个回合，自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87917187,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,87917187)
	e1:SetCost(c87917187.spcost)
	e1:SetTarget(c87917187.sptg)
	e1:SetOperation(c87917187.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87917187,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c87917187.thtg)
	e2:SetOperation(c87917187.thop)
	c:RegisterEffect(e2)
end
-- ①的效果的发动代价（解放自身）的处理函数
function c87917187.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤手卡·卡组中满足「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」且可以特殊召唤的怪兽
function c87917187.spfilter(c,e,tp)
	return c:IsCode(6007213,32491822,69890967) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①的效果的发动准备与合法性检查
function c87917187.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空格（因自身解放，可用空格数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组是否存在至少1只满足特召条件的幻魔怪兽
		and Duel.IsExistingMatchingCard(c87917187.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·卡组特召1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①的效果的实际处理函数（施加不能攻击的限制，并无视条件特召幻魔）
function c87917187.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己怪兽不能攻击。/「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从手卡·卡组无视召唤条件特殊召唤。/②：把墓地的这张卡除外才能发动。从卡组把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“这个回合自己怪兽不能攻击”的玩家效果
	Duel.RegisterEffect(e1,tp)
	-- 检查怪兽区域是否还有空格，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或卡组选择1只满足条件的幻魔怪兽
	local g=Duel.SelectMatchingCard(tp,c87917187.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 无视召唤条件将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 过滤卡组中满足「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」且能加入手卡的怪兽
function c87917187.thfilter(c)
	return c:IsCode(6007213,32491822,69890967) and c:IsAbleToHand()
end
-- ②的效果的发动准备与合法性检查
function c87917187.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只满足检索条件的幻魔怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87917187.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息（从卡组将1张卡加入手卡）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果的实际处理函数（从卡组将幻魔怪兽加入手卡并给对方确认）
function c87917187.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的幻魔怪兽
	local g=Duel.SelectMatchingCard(tp,c87917187.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
