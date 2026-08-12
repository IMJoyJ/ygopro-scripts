--海晶乙女コーラルトライアングル
-- 效果：
-- 「海晶少女」怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。
-- ①：从手卡把1只水属性怪兽送去墓地才能发动。从卡组把1张「海晶少女」陷阱卡加入手卡。
-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。连接标记合计直到变成3为止，从自己墓地选水属性连接怪兽任意数量特殊召唤。
function c84546257.initial_effect(c)
	-- 添加连接召唤手续：以「海晶少女」怪兽2只以上作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x12b),2)
	c:EnableReviveLimit()
	-- ①：从手卡把1只水属性怪兽送去墓地才能发动。从卡组把1张「海晶少女」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,84546257)
	e1:SetCost(c84546257.thcost)
	e1:SetTarget(c84546257.thtg)
	e1:SetOperation(c84546257.thop)
	c:RegisterEffect(e1)
	-- ②：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。连接标记合计直到变成3为止，从自己墓地选水属性连接怪兽任意数量特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,84546258)
	e2:SetCondition(c84546257.spcon)
	e2:SetCost(c84546257.spcost)
	e2:SetTarget(c84546257.sptg)
	e2:SetOperation(c84546257.spop)
	c:RegisterEffect(e2)
	-- 设立用于检测是否只特殊召唤了水属性怪兽的计数器
	Duel.AddCustomActivityCounter(84546257,ACTIVITY_SPSUMMON,c84546257.counterfilter)
end
-- 特殊召唤怪兽属性的计数器过滤条件：水属性怪兽
function c84546257.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 效果誓约：设置本回合不能特殊召唤水属性以外的怪兽
function c84546257.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检查自己本回合是否特殊召唤过水属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(84546257,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c84546257.splimit)
	-- 为玩家注册不能特殊召唤水属性以外怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：非水属性怪兽不能特殊召唤
function c84546257.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 手卡送墓的代价值过滤条件：水属性怪兽
function c84546257.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价处理：检查誓约限制并选择手卡1只水属性怪兽送去墓地
function c84546257.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c84546257.cost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 检查手卡中是否存在可以作为发动代价的水属性怪兽
		and Duel.IsExistingMatchingCard(c84546257.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手卡中1张满足发动代价的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c84546257.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	c84546257.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 过滤卡组中可以加入手牌的「海晶少女」陷阱卡
function c84546257.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组是否有满足条件的可检索卡片并设定操作信息
function c84546257.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「海晶少女」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c84546257.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置把卡组中的卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张「海晶少女」陷阱卡加入手牌
function c84546257.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「海晶少女」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c84546257.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：自己场上没有怪兽存在且对方场上存在怪兽
function c84546257.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果②的代价处理：检查誓约限制并将墓地的这张卡除外
function c84546257.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c84546257.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将墓地的这张卡除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	c84546257.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 特殊召唤的目标过滤条件：墓地的水属性连接怪兽
function c84546257.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的组合检查：选择怪兽的连接标记合计必须等于3
function c84546257.fselect(sg)
	return sg:GetSum(Card.GetLink)==3
end
-- 特殊召唤的组限制检查：选择怪兽的连接标记合计不能超过3
function c84546257.gcheck(sg)
	return sg:GetSum(Card.GetLink)<=3
end
-- 效果②的发动准备：检查并计算怪兽区域位置，验证是否存在满足特殊召唤条件的卡片组合并设定操作信息
function c84546257.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中满足特殊召唤条件的水属性连接怪兽
	local g=Duel.GetMatchingGroup(c84546257.spfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if chk==0 then
		if ft<=0 then return false end
		-- 设定用于手动选择时限制连接标记合计不超过3的辅助检查函数
		aux.GCheckAdditional=c84546257.gcheck
		local res=g:CheckSubGroup(c84546257.fselect,1,ft)
		-- 重置手动选择的辅助检查函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置从墓地特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：选择墓地中连接标记合计为3的水属性连接怪兽任意数量特殊召唤
function c84546257.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中满足特殊召唤条件的水属性连接怪兽（受墓地否定类效果影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c84546257.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设定用于手动选择时限制连接标记合计不超过3的辅助检查函数
	aux.GCheckAdditional=c84546257.gcheck
	local sg=g:SelectSubGroup(tp,c84546257.fselect,false,1,ft)
	-- 重置手动选择的辅助检查函数
	aux.GCheckAdditional=nil
	if sg then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
