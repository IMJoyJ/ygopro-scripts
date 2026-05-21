--神芸学徒 リテラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地把1张「神艺」卡加入手卡。
-- ②：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：对方主要阶段才能发动。从自己的手卡·墓地把「神艺学徒 莉泰拉」以外的1只「神艺」怪兽特殊召唤。那之后，场上的这张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果注册，包含①手卡特召及回收墓地、②战斗伤害变0、③对方主要阶段特召手卡/墓地怪兽并回手的效果
function s.initial_effect(c)
	-- ①：自己场上有「神艺」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地把1张「神艺」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：对方主要阶段才能发动。从自己的手卡·墓地把「神艺学徒 莉泰拉」以外的1只「神艺」怪兽特殊召唤。那之后，场上的这张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"从手卡·墓地特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「神艺」卡
function s.cfilter(c)
	return c:IsSetCard(0x1cd) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上有「神艺」卡存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「神艺」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：墓地中可以加入手卡的「神艺」卡
function s.thfilter(c)
	return c:IsSetCard(0x1cd) and c:IsAbleToHand()
end
-- 效果①的效果处理：特殊召唤自身，之后可选择将墓地1张「神艺」卡加入手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与连锁相关，则将其以表侧表示特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己墓地是否存在不受「王家长眠之谷」影响且可加入手卡的「神艺」卡
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否选择将墓地的「神艺」卡加入手卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从墓地选择1张不受「王家长眠之谷」影响的「神艺」卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的加入手卡处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 将选中的卡因效果加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果③的发动条件：对方回合的主要阶段
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合且处于主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 过滤条件：手卡或墓地中「神艺学徒 莉泰拉」以外且可以特殊召唤的「神艺」怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1cd)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备：检查怪兽区域空格及手卡·墓地中是否存在可特召的怪兽，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡或墓地是否存在满足特召条件的「神艺」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果③的效果处理：从手卡·墓地特殊召唤1只「神艺」怪兽，那之后场上的这张卡回到手卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空格，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或墓地选择1张不受「王家长眠之谷」影响且满足条件的「神艺」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsRelateToChain() and c:IsLocation(LOCATION_ONFIELD) then
		-- 中断当前效果处理，使后续的回手牌处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 将场上的这张卡因效果回到持有者手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
