--ユニオン・パイロット
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只效果怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：让装备状态的这张卡回到手卡才能发动。自己1只怪兽把可以装备的除外状态的1只同盟怪兽当作那个效果的装备魔法卡使用来装备，这张卡从自己手卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：注册同盟怪兽的标准效果，以及在魔陷区发动的②效果。
function s.initial_effect(c)
	-- 赋予该卡同盟怪兽的标准机制（装备代替破坏、装备限制、装备发动、特殊召唤），并指定只能装备给效果怪兽。
	aux.EnableUnionAttribute(c,s.eqfilter)
	-- ②：让装备状态的这张卡回到手卡才能发动。自己1只怪兽把可以装备的除外状态的1只同盟怪兽当作那个效果的装备魔法卡使用来装备，这张卡从自己手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"这张卡回到手卡"
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.recost)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.reop)
	c:RegisterEffect(e1)
end
s.has_text_type=TYPE_UNION
-- 过滤条件：作为同盟装备对象的效果怪兽。
function s.eqfilter(c)
	return c:IsType(TYPE_EFFECT)
end
-- ②效果的Cost：检查并执行将装备状态的这张卡送回手卡的操作。
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	-- 作为发动代价，将作为装备卡的这张卡送回持有者的手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
-- 过滤条件：自己场上表侧表示的、存在可装备的除外状态同盟怪兽的怪兽。
function s.tgfilter(c,e,tp)
	-- 检查自身是否处于同盟装备状态，若是，则在后续同盟装备检查中排除自身占用的装备格子计数。
	local exct=aux.IsUnionState(e) and 1 or 0
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp)
		-- 检查除外区是否存在至少1张可以装备给该怪兽的同盟怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,nil,c,tp,exct)
end
-- 过滤条件：除外区表侧表示、可以装备给目标怪兽且满足同盟装备规则的同盟怪兽。
function s.cfilter(c,ec,tp,exclude_modern_count)
	return c:IsFaceup() and c:IsType(TYPE_UNION)
		-- 检查该同盟怪兽在场上是否唯一、未被禁止、符合装备对象限制，且满足同盟怪兽的装备数量限制。
		and c:CheckUniqueOnField(tp) and not c:IsForbidden() and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec,exclude_modern_count)
end
-- ②效果的Target：检查自己场上是否有空余怪兽区域、是否能特殊召唤自身，以及是否存在符合条件的装备对象。
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤这张卡（光属性、机械族、5星、攻击力2100/守备力1000的效果怪兽）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_EFFECT+TYPE_MONSTER,2100,1000,5,RACE_MACHINE,ATTRIBUTE_LIGHT)
		-- 检查自己场上是否存在符合条件的、可以装备除外区同盟怪兽的怪兽。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 将自身（作为装备卡发动的这张卡）设为效果的处理对象。
	Duel.SetTargetCard(e:GetHandler())
	-- 设置连锁信息：包含从除外区装备1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
end
-- ②效果的Operation：选择自己场上的1只怪兽，将除外状态的1只同盟怪兽装备给它，随后将回到手卡的这张卡特殊召唤。
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要装备同盟怪兽的自己场上的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 提示玩家选择要装备的同盟怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 玩家从除外区选择1只可以装备给目标怪兽的同盟怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED,0,1,1,nil,tc,tp)
		local ec=sg:GetFirst()
		-- 如果成功选择同盟怪兽，则将其作为装备卡装备给目标怪兽。
		if ec and Duel.Equip(tp,ec,tc) then
			-- 为装备的同盟怪兽添加同盟装备状态。
			aux.SetUnionState(ec)
			if e:GetHandler():IsRelateToChain() and e:GetHandler():IsLocation(LOCATION_HAND) then
				-- 将手卡中的这张卡表侧表示特殊召唤。
				Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
