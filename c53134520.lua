--幻魔の召喚神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从自己的卡组·墓地加入手卡。那之后，可以把攻击力和守备力的数值相同的1只炎族·雷族·恶魔族的10星怪兽从手卡无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「次元融合杀」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果，包括①②两个起动效果
function s.initial_effect(c)
	-- 记录该卡与「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的关联
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 设置①效果的具体内容，包括加入手牌、特殊召唤等操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 设置②效果的具体内容，包括检索「次元融合杀」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索「次元融合杀」"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- ②效果的发动条件为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件为解放这张卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 执行解放操作
	Duel.Release(c,REASON_COST)
end
-- 定义用于检索的卡片过滤器，筛选「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
function s.thfilter(c)
	return c:IsCode(6007213,32491822,69890967) and c:IsAbleToHand()
end
-- 定义用于特殊召唤的卡片过滤器，筛选攻击力等于守备力且为炎族·雷族·恶魔族10星怪兽
function s.spfilter(c,e,tp)
	local atk=c:GetTextAttack()
	local def=c:GetTextDefense()
	return atk>=0 and def>=0 and atk==def and c:IsRace(RACE_FIEND+RACE_PYRO+RACE_THUNDER) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的发动时点处理，检查是否有满足条件的卡可加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组或墓地存在满足条件的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组·墓地检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理流程，包括选择并加入手牌、确认手牌、洗切手牌、是否特殊召唤等
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并处理后续特殊召唤逻辑
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 检查是否有满足条件的怪兽可特殊召唤且场上存在可用区域
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0
			-- 询问玩家是否要特殊召唤该怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要特殊召唤？"
			-- 选择要特殊召唤的怪兽
			local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
			-- 执行特殊召唤步骤
			if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				-- 为特殊召唤的怪兽设置不能直接攻击的效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				-- 完成特殊召唤流程
				Duel.SpecialSummonComplete()
			end
		end
	end
end
-- 定义用于检索「次元融合杀」的卡片过滤器
function s.thfilter2(c)
	return c:IsCode(89190953) and c:IsAbleToHand()
end
-- ②效果的发动时点处理，检查是否有满足条件的卡可加入手牌
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组存在满足条件的「次元融合杀」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索一张「次元融合杀」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理流程，包括选择并加入手牌、确认手牌等
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「次元融合杀」
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
