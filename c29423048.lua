--ヘルフレイムバンシー
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只炎族怪兽加入手卡或送去墓地。
-- ②：这张卡被除外的场合，若自己场上有炎族怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力直到回合结束时上升自己的除外状态的怪兽数量×100。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用4星怪兽叠放2只
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只炎族怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.scost)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，若自己场上有炎族怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力直到回合结束时上升自己的除外状态的怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果Cost：检查并移除1个超量素材作为代价
function s.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：筛选炎族怪兽，且能加入手卡或送去墓地
function s.filter(c)
	return c:IsRace(RACE_PYRO) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果Target：检查卡组是否存在满足条件的炎族怪兽
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的炎族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果Operation：选择一张炎族怪兽，加入手卡或送去墓地
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择一张满足条件的炎族怪兽
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	-- 选择将怪兽加入手卡或送去墓地
	local op=aux.SelectFromOptions(tp,{tc:IsAbleToHand(),1190},{tc:IsAbleToGrave(),1191})
	if op==1 then
		-- 将怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方查看该怪兽
		Duel.ConfirmCards(1-tp,tc)
	-- 将怪兽送去墓地
	else Duel.SendtoGrave(tc,REASON_EFFECT) end
end
-- 过滤函数：筛选场上正面表示的炎族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
-- 效果Condition：检查自己场上是否存在炎族怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在炎族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果Target：检查是否可以特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数：筛选正面表示的怪兽（用于计算除外怪兽数量）
function s.afilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果Operation：特殊召唤此卡，并根据除外怪兽数量提升攻击力
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能参与特殊召唤流程
	if not (c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)) then return end
	-- 统计除外状态的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.afilter,tp,LOCATION_REMOVED,0,nil)
	if ct>0 then
		-- 给特殊召唤的此卡增加攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
