--武神帝－ツクヨミ
-- 效果：
-- 光属性4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。手卡全部送去墓地，从卡组抽2张卡。此外，这张卡因对方的卡的效果从场上离开时，可以从自己墓地选择最多有那个时候这张卡持有的超量素材数量的4星的名字带有「武神」的兽战士族怪兽特殊召唤。「武神帝-月读」在自己场上只能有1只表侧表示存在。
function c73289035.initial_effect(c)
	c:SetUniqueOnField(1,0,73289035)
	-- 添加XYZ召唤手续：光属性4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。手卡全部送去墓地，从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73289035,0))  --"抽卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c73289035.cost)
	e1:SetTarget(c73289035.target)
	e1:SetOperation(c73289035.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡因对方的卡的效果从场上离开时，可以从自己墓地选择最多有那个时候这张卡持有的超量素材数量的4星的名字带有「武神」的兽战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73289035,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c73289035.spcon)
	e2:SetTarget(c73289035.sptg)
	e2:SetOperation(c73289035.spop)
	c:RegisterEffect(e2)
end
-- 效果1的代价：把这张卡1个超量素材取除
function c73289035.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果1的发动准备：检查是否能抽卡且手卡数量大于0，并设置送去墓地和抽卡的操作信息
function c73289035.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否能抽2张卡，且手卡数量至少有1张
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置操作信息：效果处理时玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息：效果处理时将手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_HAND)
end
-- 效果1的效果处理：将手卡全部送去墓地，并从卡组抽2张卡
function c73289035.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的所有手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()>0 then
		-- 将手卡全部送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- 效果2的发动条件：因对方卡的效果从场上表侧表示离开，且离场时持有超量素材
function c73289035.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetPreviousOverlayCountOnField()
	e:SetLabel(ct)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and ct>0
		and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤条件：墓地中等级4、名字带有「武神」的兽战士族怪兽，且能特殊召唤
function c73289035.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备：检查怪兽区域空位，选择墓地中符合条件的怪兽作为对象，并设置特殊召唤的操作信息
function c73289035.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73289035.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c73289035.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>ft then ct=ft end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地最多有离场时超量素材数量的符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73289035.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置操作信息：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果2的效果处理：将选择的对象怪兽在自己场上特殊召唤
function c73289035.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与该效果关联的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<g:GetCount() then return end
	if g:GetCount()>0 then
		-- 将符合条件的对象怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
