--エクシーズ・アンブレイカブル・バリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有超量怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。那之后，可以把自己场上2个超量素材取除。那个场合，再把场上1张卡破坏。
-- ②：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。从自己墓地把1只光属性「霍普」超量怪兽作为成为对象的怪兽的超量素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动无效并可选破坏）和②效果（墓地除外给超量怪兽叠放素材）
function s.initial_effect(c)
	-- ①：自己场上有超量怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。那之后，可以把自己场上2个超量素材取除。那个场合，再把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。从自己墓地把1只光属性「霍普」超量怪兽作为成为对象的怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"成为素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动成本为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的超量怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
end
-- ①效果的发动条件：怪兽的效果·魔法·陷阱卡发动时，且自己场上有表侧表示的超量怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的超量怪兽
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备：设置无效发动的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①效果的处理：无效发动，并可选去除2个素材来破坏场上1张卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效发动，且自己场上存在至少2个可以被效果去除的超量素材
	if Duel.NegateActivation(ev) and Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_EFFECT)
		-- 且场上存在至少1张除这张卡以外的卡（作为破坏对象）
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
		-- 询问玩家是否选择发动“去除素材并破坏卡”的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
		-- 中断当前效果处理，使后续的“去除素材”与“无效发动”不视为同时处理
		Duel.BreakEffect()
		-- 如果成功去除自己场上2个超量素材
		if Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_EFFECT)~=0 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上1张除这张卡以外的卡
			local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续的“破坏”与“去除素材”不视为同时处理
				Duel.BreakEffect()
				-- 为选中的卡片显示被选择的动画效果
				Duel.HintSelection(g)
				-- 将选中的卡片破坏
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
-- 过滤条件：表侧表示的超量怪兽
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 过滤条件：墓地中可以作为超量素材的光属性「霍普」超量怪兽
function s.matfilter(c)
	return c:IsSetCard(0x7f) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ) and c:IsCanOverlay()
end
-- ②效果的发动准备：选择自己场上1只超量怪兽为对象，并确认墓地有符合条件的素材
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 且自己墓地是否存在符合条件的素材卡
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理：将自己墓地1只光属性「霍普」超量怪兽作为成为对象的怪兽的超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己墓地选择1只符合条件且不受「王家长眠之谷」影响的光属性「霍普」超量怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡作为超量素材重叠在目标怪兽下面
			Duel.Overlay(tc,g)
		end
	end
end
