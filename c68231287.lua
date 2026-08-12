--壊獄神ユピテル
-- 效果：
-- 10星怪兽×3
-- 「坏狱神 朱庇特」1回合1次也能在有装备卡3张以上装备的自己怪兽上面重叠来超量召唤。
-- ①：这张卡超量召唤的场合才能发动。把这张卡可以装备的装备魔法卡任意数量从自己墓地装备。
-- ②：有超量怪兽在作为素材中的这张卡的攻击力上升3000。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。从自己墓地把1只「终刻」怪兽特殊召唤。那之后，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：包含重叠超量召唤手续、①效果（超量召唤成功时装备墓地装备魔法）、②效果（有超量怪兽作为素材时攻击力上升）、③效果（去除素材特召墓地「终刻」怪兽并可选破坏场上卡片）
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,10,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在有装备卡的怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。把这张卡可以装备的装备魔法卡任意数量从自己墓地装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ②：有超量怪兽在作为素材中的这张卡的攻击力上升3000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(3000)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。从自己墓地把1只「终刻」怪兽特殊召唤。那之后，可以把场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤重叠超量召唤所需的自己场上的怪兽：表侧表示且装备卡在3张以上
function s.ovfilter(c)
	return c:IsFaceup() and c:GetEquipCount()>2
end
-- 重叠超量召唤时的操作，用于限制该特殊超量召唤方式每回合只能使用1次
function s.xyzop(e,tp,chk)
	-- 检查本回合是否已使用过该特殊超量召唤方式
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册本回合已使用过该特殊超量召唤方式的玩家标记
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 检查此卡是否是通过超量召唤特殊召唤的，作为①效果的发动条件
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤墓地中可以装备给此卡的装备魔法卡
function s.eqfilter(c,tp,ec)
	return c:IsType(TYPE_EQUIP) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and c:CheckEquipTarget(ec)
end
-- ①效果的发动准备（Target），检查魔法与陷阱区域是否有空位，以及墓地是否存在可装备的卡
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1张满足装备条件的卡
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
end
-- ①效果的处理（Operation），将墓地中任意数量的可装备卡装备给此卡
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToChain() then return end
	-- 获取自己场上可用的魔法与陷阱区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<1 then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地选择最多等同于空余魔陷格数量的、可装备给此卡的装备魔法卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,ft,nil,tp,c)
	if g:GetCount()>0 then
		-- 遍历选中的装备卡
		for tc in aux.Next(g) do
			-- 将选中的卡作为装备卡装备给此卡（分步处理）
			Duel.Equip(tp,tc,c,false,true)
		end
		-- 完成装备卡装备流程，触发相关时点
		Duel.EquipComplete()
	end
end
-- ②效果的适用条件：检查此卡的超量素材中是否存在超量怪兽
function s.atkcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
-- ③效果的发动代价（Cost）：取除此卡的1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤自己墓地中可以特殊召唤的「终刻」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动准备（Target），检查怪兽区域是否有空位，以及墓地是否存在可特召的「终刻」怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可特殊召唤的「终刻」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果的处理（Operation），特殊召唤墓地的「终刻」怪兽，之后可以选择破坏场上1张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只「终刻」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤到自己场上
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 询问玩家是否选择发动后续的破坏效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡破坏？"
		-- 中断效果处理，使特殊召唤与破坏不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从双方场上选择1张卡
		local sg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
		-- 闪烁显示被选中的卡片
		Duel.HintSelection(sg)
		-- 破坏选中的卡片
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
