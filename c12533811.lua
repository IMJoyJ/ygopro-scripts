--ベビー・トラゴン
-- 效果：
-- 1星怪兽×3
-- 自己的主要阶段1把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只1星的怪兽才能发动。选择的怪兽可以直接攻击对方玩家。
function c12533811.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：将任意等级1的怪兽3只叠放作为超量素材来进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- 自己的主要阶段1把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只1星的怪兽才能发动。选择的怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12533811,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12533811.condition)
	e1:SetCost(c12533811.cost)
	e1:SetTarget(c12533811.target)
	e1:SetOperation(c12533811.operation)
	c:RegisterEffect(e1)
end
-- 该效果的发动条件判定函数：仅在当前阶段为主要阶段1时才允许发动。
function c12533811.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前游戏阶段是否为主要阶段1，是则返回真，使效果满足发动条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 发动代价处理：先检查能否从这张卡上取除1个超量素材作为代价；可以则实际取除1个超量素材（REASON_COST）。
function c12533811.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象筛选条件：选择自己场上表侧表示、等级为1，且尚未受到“可以直接攻击”效果影响的怪兽。
function c12533811.filter(c)
	return c:IsFaceup() and c:IsLevel(1) and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 效果发动时的取对象处理：在有合法对象的前提下，让玩家从自己场上表侧表示的1星怪兽中选择1只作为对象。
function c12533811.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c12533811.filter(chkc) end
	-- 在效果发动时检查是否存在至少1只满足条件的自己场上的表侧1星怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c12533811.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择提示信息：‘请选择表侧表示的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示的1星怪兽中精确选择1张，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c12533811.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获得对象怪兽，若其仍表侧表示且与效果已关联，则给它附加‘可以直接攻击’的单体效果，并在标准重置时机（离场、翻转等）自动失效。
function c12533811.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中登记的对象怪兽（即发动时选择的1只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
