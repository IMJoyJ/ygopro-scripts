--ドレミコード・ソルフェージア
-- 效果：
-- ←9 【灵摆】 9→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：由对方在场上发动的怪兽的效果的处理时，自己场上有「大钢琴之七音服」怪兽存在的场合，可以把那个发动的效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「七音服」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动（也能把这张卡解放来发动）。从手卡把「七音服·索尔费吉娅」以外的1只「七音服」怪兽特殊召唤。把这张卡解放发动的场合，也能从自己的额外卡组（表侧）·墓地选特殊召唤的怪兽。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆效果、手卡特召效果和场上特召效果
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：由对方在场上发动的怪兽的效果的处理时，自己场上有「大钢琴之七音服」怪兽存在的场合，可以把那个发动的效果无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽不存在的场合或者只有「七音服」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动（也能把这张卡解放来发动）。从手卡把「七音服·索尔费吉娅」以外的1只「七音服」怪兽特殊召唤。把这张卡解放发动的场合，也能从自己的额外卡组（表侧）·墓地选特殊召唤的怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「大钢琴之七音服」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1162)
end
-- 灵摆效果无效发动的条件判断函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的效果，且本回合尚未适用过此效果
	return rp==1-tp and Duel.GetFlagEffect(tp,id)==0
		-- 检查该效果是否在场上（怪兽区域）发动
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上是否存在表侧表示的「大钢琴之七音服」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查该连锁效果是否可以被无效，且当前未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 灵摆效果无效发动的处理函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认本回合尚未适用过此效果
	if Duel.GetFlagEffect(tp,id)==0
		-- 询问玩家是否适用此效果来无效对方的效果
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then  --"是否适用「七音服·索尔费吉娅」的效果来无效？"
		-- 在场上显示此卡发动的动画提示
		Duel.Hint(HINT_CARD,0,id)
		-- 为玩家注册本回合已适用此效果的标记（一回合只能使用一次）
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 尝试无效该连锁的效果，若成功则执行后续处理
		if Duel.NegateEffect(ev) then
			-- 产生时点中断，使无效和破坏不视为同时处理
			Duel.BreakEffect()
			-- 将作为灵摆卡存在的这张卡破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 过滤条件：里侧表示的怪兽，或者不是「七音服」怪兽
function s.cfilter2(c)
	return c:IsFacedown() or not c:IsSetCard(0x162)
end
-- 怪兽效果①特殊召唤的条件判断函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在怪兽，或者只有「七音服」怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 怪兽效果①特殊召唤的目标确认与效果声明函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①特殊召唤的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果②特殊召唤的Cost处理函数，判断是否解放自身发动
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取手卡、墓地、额外卡组中所有满足特召条件的「七音服」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp,c:IsReleasable(),c)
	if chk==0 then return g:GetCount()>0 end
	-- 若场上有空位且手卡有可特召怪兽，且玩家选择不解放此卡（或此卡无法解放）时，不解放此卡发动
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and (not c:IsReleasable() or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否解放来发动？"
		e:SetLabel(0)
	else
		-- 解放这张卡作为发动的Cost
		Duel.Release(c,REASON_COST)
		e:SetLabel(1)
	end
end
-- 过滤条件：除「七音服·索尔费吉娅」以外的「七音服」怪兽，且满足在对应区域特殊召唤的条件
function s.spfilter2(c,e,tp,res,rc)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x162)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (res and (not c:IsLocation(LOCATION_EXTRA)
		-- 检查解放此卡后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,rc)>0
		-- 检查解放此卡后，是否有可用于从额外卡组特殊召唤怪兽的区域
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0)
		-- 检查不解放此卡时，从手卡特殊召唤所需的怪兽区域
		or c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
-- 怪兽效果②特殊召唤的目标确认与效果声明函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段检查是否存在至少1只满足特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,c:IsReleasable(),c) end
	local loc=LOCATION_HAND
	if e:GetLabel()==1 then
		loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA
	end
	-- 设置特殊召唤对应区域怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
-- 怪兽效果②特殊召唤的处理函数
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local res=false
	if e:GetLabel()==1 then
		res=true
	end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡（若未解放）或手卡·墓地·额外卡组（若已解放）中选择1只「七音服」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp,res,nil)
	if #g>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
