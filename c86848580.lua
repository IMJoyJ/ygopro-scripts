--零鳥獣シルフィーネ
-- 效果：
-- 鸟兽族4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上表侧表示存在的全部卡的效果无效，这张卡的攻击力上升这张卡以外的场上表侧表示存在的卡数量×300的数值。这张卡的效果直到下次的自己的准备阶段时适用。
function c86848580.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只4星的鸟兽族怪兽
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上表侧表示存在的全部卡的效果无效，这张卡的攻击力上升这张卡以外的场上表侧表示存在的卡数量×300的数值。这张卡的效果直到下次的自己的准备阶段时适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86848580,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c86848580.discost)
	e1:SetTarget(c86848580.distg)
	e1:SetOperation(c86848580.disop)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：取除这张卡的1个超量素材
function c86848580.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标：检查对方场上是否存在可以无效的表侧表示卡片
function c86848580.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张表侧表示且可以被无效的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 效果处理：使对方场上所有表侧表示卡片的效果无效，并根据场上其他表侧表示卡片的数量提升自身的攻击力，这些效果持续到下次自己的准备阶段
function c86848580.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示且可以被无效的卡片
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	while tc do
		-- 对方场上表侧表示存在的全部卡的效果无效...这张卡的效果直到下次的自己的准备阶段时适用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		tc:RegisterEffect(e1)
		-- 对方场上表侧表示存在的全部卡的效果无效...这张卡的效果直到下次的自己的准备阶段时适用。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对方场上表侧表示存在的全部卡的效果无效...这张卡的效果直到下次的自己的准备阶段时适用。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 计算除这张卡以外场上表侧表示存在的卡片数量乘以300的攻击力上升值
	local atk=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)*300
	if atk>0 then
		-- 这张卡的攻击力上升这张卡以外的场上表侧表示存在的卡数量×300的数值。这张卡的效果直到下次的自己的准备阶段时适用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_STANDBY,2)
		c:RegisterEffect(e1)
	end
end
