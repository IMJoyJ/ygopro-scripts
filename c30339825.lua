--万物の始源-「水」
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽的持有者场上1只水属性怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只水属性怪兽为对象才能发动。那只怪兽的持有者场上1只怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
local s,id,o=GetID()
-- 定义并注册该卡的两个效果：e1为魔法卡发动效果（①），e2为墓地除外自身发动的起动效果（②）；两者通过SetCountLimit(1,id)共享‘这个卡名的①②效果1回合只能使用其中任意1个’的次数限制。
function s.initial_effect(c)
	-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽的持有者场上1只水属性怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target(nil))
	e1:SetOperation(s.activate(nil))
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己或对方的墓地1只水属性怪兽为对象才能发动。那只怪兽的持有者场上1只怪兽破坏，作为对象的怪兽在那个场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外并发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	-- 设置效果②的发动条件：这张卡不是在这个回合被送去墓地的场合才能发动，即满足‘这个回合没有送去墓地’的条件。
	e2:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：将墓地中的这张卡除外作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target(ATTRIBUTE_WATER))
	e2:SetOperation(s.activate(ATTRIBUTE_WATER))
	c:RegisterEffect(e2)
end
-- 定义可作为对象的墓地怪兽的筛选条件：属性符合要求（②限定水属性，①无限制），能被效果特殊召唤为表侧守备表示到其持有者场上，且其持有者场上存在满足后续破坏条件的表侧怪兽。
function s.spfilter(c,e,tp,att)
	if att and not c:IsAttribute(ATTRIBUTE_WATER) then return false end
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,c:GetOwner())
		-- 同时检查该怪兽持有者场上是否存在至少1只表侧表示且可被破坏（破坏后有空位）的怪兽，以保证效果处理时能破坏怪兽并腾出特殊召唤区域。
		and Duel.IsExistingMatchingCard(s.desfilter,c:GetOwner(),LOCATION_MZONE,0,1,nil,c:GetOwner(),att,tp)
end
-- 定义要破坏的怪兽的筛选条件：①（att为空）时需为水属性；②（att为WATER）时任意属性；且为表侧表示，并在破坏后其持有者场上存在可用的怪兽区。
function s.desfilter(c,p,att,rp)
	if not att and not c:IsAttribute(ATTRIBUTE_WATER) then return false end
	-- 判断该怪兽是表侧表示，且将其破坏后其持有者场上仍有可用的怪兽区（用于特殊召唤对象怪兽）。
	return c:IsFaceup() and Duel.GetMZoneCount(p,c,rp)>0
end
-- 定义效果发动时的目标选择流程：合法性检查是否存在可选的墓地怪兽；发动时从双方墓地选择1只符合条件的怪兽作为对象，并取得该怪兽持有者场上的怪兽组，登记破坏与特殊召唤的操作信息。
function s.target(att)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,att) end
			-- 在发动合法性检查（chk==0）时，确认双方墓地存在至少1只可作为对象且满足特殊召唤/破坏条件的怪兽；否则不能发动。
			if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,att) end
			-- 显示‘请选择要特殊召唤的卡’的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从双方墓地选择1只符合条件的怪兽，并将其登记为当前连锁的对象卡。
			local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,att)
			local gc=g:GetFirst()
			-- 取得对象怪兽持有者场上的全部怪兽（用于后续选择其中1只破坏）。
			local dg=Duel.GetFieldGroup(gc:GetOwner(),LOCATION_MZONE,0)
			-- 登记本连锁将破坏1张卡：可能破坏的对象是dg（对象怪兽持有者场上的怪兽），用于后续效果联动判定。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
			-- 登记本连锁将特殊召唤1张卡：对象怪兽g，用于后续效果联动判定。
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		end
end
-- 定义效果处理时的操作：取得对象怪兽，确认其未被移离；由该怪兽持有者场上选择1只应破坏的怪兽（①水属性，②任意），破坏成功后，若对象怪兽不受王家长眠之谷等从墓地特殊召唤限制，则将其表侧守备表示特殊召唤到持有者场上。
function s.activate(att)
	return function(e,tp,eg,ep,ev,re,r,rp)
			-- 获取当前连锁中登记的对象卡（即效果发动时选择的墓地怪兽）。
			local tc=Duel.GetFirstTarget()
			if not tc:IsRelateToEffect(e) then return end
			local sp=tc:GetOwner()
			-- 显示‘请选择要破坏的卡’的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 由当前玩家从对象怪兽持有者场上选择1只表侧表示且满足破坏条件的怪兽（①需水属性，②任意）。
			local g=Duel.SelectMatchingCard(tp,s.desfilter,sp,LOCATION_MZONE,0,1,1,nil,sp,att,tp)
			if g then
				-- 显示被选择破坏的怪兽的选中动画，并记录其为广义对象。
				Duel.HintSelection(g)
				-- 实际破坏选中的怪兽；若破坏成功，且对象怪兽不受王家长眠之谷等效果影响而无法从墓地特殊召唤，则继续处理特殊召唤。
				if Duel.Destroy(g,REASON_EFFECT)~=0 and aux.NecroValleyFilter()(tc) then
					-- 将对象怪兽以表侧守备表示特殊召唤到其持有者（sp）的场上。
					Duel.SpecialSummon(tc,0,tp,sp,false,false,POS_FACEUP_DEFENSE)
				end
			end
		end
end
