--幻魔の召喚神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从自己的卡组·墓地加入手卡。那之后，可以把攻击力和守备力的数值相同的1只炎族·雷族·恶魔族的10星怪兽从手卡无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「次元融合杀」加入手卡。
local s,id,o=GetID()
-- 注册『幻魔之召唤神』的两个起动效果：①场上解放自身，检索三幻魔之一并可追加特殊召唤；②墓地除外自身检索『次元融合杀』。两个效果每回合各限1次。
function s.initial_effect(c)
	-- 将『神炎皇 乌利亚』『降雷皇 哈蒙』『幻魔皇 拉比艾尔』的卡号加入代码列表，使此卡被判定为记载有这些卡名。
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡解放才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只从自己的卡组·墓地加入手卡。那之后，可以把攻击力和守备力的数值相同的1只炎族·雷族·恶魔族的10星怪兽从手卡无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
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
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「次元融合杀」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索「次元融合杀」"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：把墓地中的这张卡除外（使用辅助函数aux.bfgcost完成）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 效果①的代价函数：检查这张卡是否可解放，若可则将其解放作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 以代价（REASON_COST）解放这张卡。
	Duel.Release(c,REASON_COST)
end
-- 检索过滤器：卡名必须是『神炎皇 乌利亚』『降雷皇 哈蒙』『幻魔皇 拉比艾尔』其中之一，且可以被加入手牌。
function s.thfilter(c)
	return c:IsCode(6007213,32491822,69890967) and c:IsAbleToHand()
end
-- 特殊召唤过滤器：卡面攻击力与守备力数值相同，种族为炎族·雷族·恶魔族，等级为10星，且能被效果无视召唤条件特殊召唤。
function s.spfilter(c,e,tp)
	local atk=c:GetTextAttack()
	local def=c:GetTextDefense()
	return atk>=0 and def>=0 and atk==def and c:IsRace(RACE_FIEND+RACE_PYRO+RACE_THUNDER) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的发动时处理：确认卡组·墓地存在可检索的三幻魔之一；设置操作信息为从卡组·墓地加入1张卡到手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组·墓地是否存在至少1只满足s.thfilter的三幻魔。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次效果将处理从卡组·墓地加入1张卡到手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的解决处理：从卡组·墓地选择1只三幻魔加入手牌并给对方确认；之后，若手牌中存在满足s.spfilter的怪兽且自己场上怪兽区有空位，则询问玩家是否特殊召唤，并给特殊召唤的怪兽附加“本回合不能直接攻击”的效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地选择1张满足s.thfilter的卡（三幻魔之一）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 若成功选择到卡且将其加入手牌成功（实际加入数量>0），则继续执行后续处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手牌（重置手牌顺序相关状态）。
		Duel.ShuffleHand(tp)
		-- 判断手牌中是否存在满足s.spfilter的怪兽，且自己场上怪兽区有空位。
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0
			-- 询问玩家是否要特殊召唤符合条件的怪兽（选择“是”则继续）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要特殊召唤？"
			-- 从手牌选择1只满足s.spfilter的怪兽作为特殊召唤对象。
			local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
			-- 以无视召唤条件、表侧表示的方式将选择的怪兽特殊召唤（分步处理）；若成功则继续。
			if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				-- 这个效果特殊召唤的怪兽在这个回合不能直接攻击。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				-- 完成特殊召唤处理（与Duel.SpecialSummonStep配对使用，结束分步特殊召唤）。
				Duel.SpecialSummonComplete()
			end
		end
	end
end
-- 检索过滤器：卡名必须是『次元融合杀』且可以被加入手牌。
function s.thfilter2(c)
	return c:IsCode(89190953) and c:IsAbleToHand()
end
-- 效果②的发动时处理：确认卡组中存在『次元融合杀』；设置操作信息为从卡组加入1张卡到手牌。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组是否存在『次元融合杀』。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将处理从卡组加入1张卡到手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的解决处理：从卡组选择1张『次元融合杀』加入手牌，并给对方确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足s.thfilter2的卡（『次元融合杀』）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的『次元融合杀』加入手牌（原因为效果），返回实际加入数量。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
