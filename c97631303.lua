--マジシャンズ・ソウルズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，可以从卡组把1只6星以上的魔法师族怪兽送去墓地，从以下效果选择1个发动。
-- ●这张卡特殊召唤。
-- ●这张卡送去墓地。那之后，可以从自己墓地把1只「黑魔术师」或「黑魔术少女」特殊召唤。
-- ②：从自己的手卡·场上把最多2张魔法·陷阱卡送去墓地才能发动。自己抽出送去墓地的数量。
function c97631303.initial_effect(c)
	-- 注册该卡片记有「黑魔术师」和「黑魔术少女」的卡片密码。
	aux.AddCodeList(c,46986414,38033121)
	-- ①：这张卡在手卡存在的场合，可以从卡组把1只6星以上的魔法师族怪兽送去墓地，从以下效果选择1个发动。●这张卡特殊召唤。●这张卡送去墓地。那之后，可以从自己墓地把1只「黑魔术师」或「黑魔术少女」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,97631303)
	e1:SetCost(c97631303.spcost)
	e1:SetTarget(c97631303.sptg)
	e1:SetOperation(c97631303.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把最多2张魔法·陷阱卡送去墓地才能发动。自己抽出送去墓地的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,97631304)
	e2:SetCost(c97631303.drcost)
	e2:SetTarget(c97631303.drtg)
	e2:SetOperation(c97631303.drop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中等级6以上且可以送去墓地的魔法师族怪兽。
function c97631303.cfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：从卡组将1只6星以上的魔法师族怪兽送去墓地。
function c97631303.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的6星以上魔法师族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c97631303.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的6星以上魔法师族怪兽。
	local g=Duel.SelectMatchingCard(tp,c97631303.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的目标选择与效果分支判定。
function c97631303.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否可以特殊召唤且怪兽区域有空位（分支1可行性）。
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=c:IsAbleToGrave()
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 只能选择分支1“这张卡特殊召唤”。
		s=Duel.SelectOption(tp,aux.Stringid(97631303,0))  --"这张卡特殊召唤"
	elseif not b1 and b2 then
		-- 只能选择分支2“这张卡送去墓地”。
		s=Duel.SelectOption(tp,aux.Stringid(97631303,1))+1  --"这张卡送去墓地"
	elseif b1 and b2 then
		-- 让玩家在“这张卡特殊召唤”和“这张卡送去墓地”两个分支中选择一个。
		s=Duel.SelectOption(tp,aux.Stringid(97631303,0),aux.Stringid(97631303,1))  --"这张卡特殊召唤/这张卡送去墓地"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置连锁信息：包含特殊召唤自身的操作。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
		-- 设置连锁信息：包含将自身送去墓地的操作。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	end
end
-- 过滤墓地中可以特殊召唤的「黑魔术师」或「黑魔术少女」。
function c97631303.spfilter(c,e,tp)
	return c:IsCode(46986414,38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理：根据玩家的选择执行特殊召唤自身，或者将自身送墓并尝试从墓地特殊召唤「黑魔术师」或「黑魔术少女」。
function c97631303.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 and c:IsRelateToEffect(e) then
		-- 将这张卡在自身场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:GetLabel()==1 and c:IsRelateToEffect(e)
		-- 检查是否成功将这张卡通过效果送去墓地且其确实存在于墓地。
		and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE)
		-- 检查自身怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在不受「王家长眠之谷」影响且可特殊召唤的「黑魔术师」或「黑魔术少女」。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c97631303.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择从墓地特殊召唤怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(97631303,2)) then  --"是否从墓地特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理（造成错时点）。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从墓地选择1只不受「王家长眠之谷」影响的「黑魔术师」或「黑魔术少女」。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97631303.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的怪兽表侧表示特殊召唤到玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手牌或场上可以送去墓地作为代价的魔法·陷阱卡。
function c97631303.drfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价：从手牌·场上将最多2张魔法·陷阱卡送去墓地。
function c97631303.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在至少1张可以送去墓地的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c97631303.drfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	local ct=1
	-- 如果玩家可以抽2张卡，则将最大可选数量设为2。
	if Duel.IsPlayerCanDraw(tp,2) then ct=2 end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌或场上选择1到2张魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c97631303.drfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,ct,nil)
	-- 将选中的卡送去墓地，并将实际送去墓地的卡片数量记录在效果的Label中。
	e:SetLabel(Duel.SendtoGrave(g,REASON_COST))
end
-- 效果②的目标确认与抽卡信息注册。
function c97631303.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	-- 设置效果处理的对象玩家为当前发动效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为送去墓地的卡片数量。
	Duel.SetTargetParam(ct)
	-- 设置连锁信息：包含让玩家抽对应数量卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果②的处理：玩家抽出送去墓地的数量的卡。
function c97631303.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家因效果抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
