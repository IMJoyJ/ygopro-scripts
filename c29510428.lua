--召煌女クインクエリ
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以自己或对方的墓地1只5星怪兽为对象才能发动。那只怪兽在自己或对方的场上特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的5星怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组选1只5星怪兽加入手卡或特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加XYZ召唤手续，要求使用等级为5、数量为2的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己或对方的墓地1只5星怪兽为对象才能发动。那只怪兽在自己或对方的场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己场上的表侧表示的5星怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组选1只5星怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 支付效果代价，移除1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的怪兽，判断是否可以特殊召唤到己方或对方场上
function s.spfilter(c,e,tp)
	-- 己方场上存在空位且该怪兽可以特殊召唤到己方场上
	return c:IsLevel(5) and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 对方场上存在空位且该怪兽可以特殊召唤到对方场上
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 设置效果目标，选择墓地中的5星怪兽作为目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查是否存在满足条件的墓地怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的5星怪兽作为目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果操作，根据选择将目标怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断己方场上是否可以将目标怪兽特殊召唤
	local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 判断对方场上是否可以将目标怪兽特殊召唤
	local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	-- 让玩家选择将怪兽特殊召唤到己方或对方场上
	local toplayer=aux.SelectFromOptions(tp,
		{s1,aux.Stringid(id,1),tp},  --"在自己场上特殊召唤"
		{s2,aux.Stringid(id,2),1-tp})  --"在对方场上特殊召唤"
	if toplayer~=nil then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,toplayer,false,false,POS_FACEUP)
	end
end
-- 判断怪兽是否因战斗或效果离开场上且等级为5
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousLevelOnField()==5 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断是否满足效果发动条件，即己方场上5星怪兽因对方效果离开
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤满足条件的卡，判断是否可以加入手牌或特殊召唤
function s.dfilter(c,e,tp,ft)
	return c:IsLevel(5) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 设置第二个效果的目标，选择卡组中满足条件的5星怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否存在满足条件的卡组怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- 处理第二个效果的操作，选择卡组中的5星怪兽并决定加入手牌或特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择满足条件的5星怪兽
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 如果怪兽不能加入手牌，则由玩家选择是否特殊召唤
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将怪兽特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将怪兽加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方看到该怪兽加入手牌
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
