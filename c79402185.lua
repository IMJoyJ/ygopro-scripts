--ボンディング－D2O
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把自己的手卡·场上2只「氘素龙」和1只「氧素龙」解放才能发动。从自己的手卡·卡组·墓地选1只「水龙」或者「水龙-团簇」当作「结合术-H2O」的效果特殊召唤。
-- ②：这张卡在墓地存在，「水龙」或者「水龙-团簇」从场上送去自己墓地的场合发动。墓地的这张卡回到手卡。
function c79402185.initial_effect(c)
	-- 注册该卡效果中涉及到的相关卡片密码（氘素龙、氧素龙、水龙-团簇、水龙）
	aux.AddCodeList(c,43017476,58071123,6022371,85066822)
	-- ①：把自己的手卡·场上2只「氘素龙」和1只「氧素龙」解放才能发动。从自己的手卡·卡组·墓地选1只「水龙」或者「水龙-团簇」当作「结合术-H2O」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c79402185.cost)
	e1:SetTarget(c79402185.target)
	e1:SetOperation(c79402185.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，「水龙」或者「水龙-团簇」从场上送去自己墓地的场合发动。墓地的这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,79402185)
	e2:SetCondition(c79402185.thcon)
	e2:SetTarget(c79402185.thtg)
	e2:SetOperation(c79402185.thop)
	c:RegisterEffect(e2)
end
-- 创建用于检查解放素材是否满足2张「氘素龙」和1张「氧素龙」的条件检查函数数组
c79402185.spchecks=aux.CreateChecks(Card.IsCode,{43017476,43017476,58071123})
-- 过滤自己手卡或场上可作为解放素材的「氘素龙」和「氧素龙」
function c79402185.costfilter(c,tp)
	return c:IsCode(43017476,58071123) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查选定的解放卡片组在解放后是否能留出足够的怪兽区域，且这些卡片是否确实可以被解放
function c79402185.fgoal(g,tp)
	-- 检查解放选定卡片后是否有可用的怪兽区域，且选定的卡片组是否满足解放条件
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- 效果①的发动代价处理函数，用于检查并执行解放2只「氘素龙」和1只「氧素龙」的操作
function c79402185.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家手卡和场上所有可解放的「氘素龙」和「氧素龙」
	local g=Duel.GetReleaseGroup(tp,true):Filter(c79402185.costfilter,nil,tp)
	if chk==0 then return g:CheckSubGroupEach(c79402185.spchecks,c79402185.fgoal,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,c79402185.spchecks,false,c79402185.fgoal,tp)
	-- 扣除代替解放效果的使用次数
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选定的卡片作为发动代价解放
	Duel.Release(rg,REASON_COST)
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「水龙」或「水龙-团簇」
function c79402185.filter(c,e,tp)
	return c:IsCode(85066822,6022371) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果①的发动检测与效果注册函数，检查是否存在可特殊召唤的怪兽并设置特殊召唤的操作信息
function c79402185.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用的怪兽区域（若已支付解放代价则无需重复检查怪兽区域）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手卡、卡组、墓地是否存在至少1只满足特殊召唤条件的「水龙」或「水龙-团簇」
		return res and Duel.IsExistingMatchingCard(c79402185.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置连锁处理中的操作信息，表示将从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的效果处理函数，从手卡、卡组、墓地选择1只「水龙」或「水龙-团簇」特殊召唤
function c79402185.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无可用区域则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只满足条件的「水龙」或「水龙-团簇」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c79402185.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
-- 效果②的发动条件检查函数，检查是否有「水龙」或「水龙-团簇」从场上送去自己墓地
function c79402185.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c79402185.thfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 过滤从场上送去墓地的「水龙」或「水龙-团簇」
function c79402185.thfilter(c)
	return (c:IsCode(85066822) or c:IsCode(6022371)) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的发动检测与效果注册函数，设置回收墓地中这张卡的操作信息
function c79402185.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中的操作信息，表示将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数，将墓地的这张卡加入手卡
function c79402185.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
