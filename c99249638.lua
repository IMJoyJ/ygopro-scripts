--ユニオン・ドライバー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只表侧表示怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：把装备状态的这张卡除外才能发动。这张卡装备过的怪兽把可以装备的1只4星以下的同盟怪兽当作那个效果的装备魔法卡使用从卡组装备。
function c99249638.initial_effect(c)
	-- 调用 aux.EnableUnionAttribute 为本卡注册同盟怪兽的通用效果：可在主要阶段将自身作为装备魔法卡装备给自己场上的表侧表示怪兽，装备怪兽被战斗·效果破坏时由本卡代替破坏，装备状态下也可解除装备特殊召唤；filter=aux.TRUE 表示对装备对象无额外限制。
	aux.EnableUnionAttribute(c,aux.TRUE)
	-- 这个卡名的②的效果1回合只能使用1次。②：把装备状态的这张卡除外才能发动。这张卡装备过的怪兽把可以装备的1只4星以下的同盟怪兽当作那个效果的装备魔法卡使用从卡组装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(99249638,2))  --"更换装备"
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,99249638)
	e4:SetCost(c99249638.recost)
	e4:SetTarget(c99249638.retg)
	e4:SetOperation(c99249638.reop)
	c:RegisterEffect(e4)
end
c99249638.has_text_type=TYPE_UNION
-- ②效果的发动代价处理函数：先记录这张卡当前装备的怪兽到标签中，然后判断能否将装备状态的这张卡除外作为发动代价；若可以则实际将其表侧除外。
function c99249638.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	e:SetLabelObject(tc)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡以表侧表示除外，作为发动②效果的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义从卡组选择同盟怪兽的过滤条件：候选卡必须是4星以下的同盟怪兽，且能作为同盟装备装备给目标怪兽，同时要满足同名卡在场限制、不是禁止卡等条件。
function c99249638.refilter(c,tc,tp,exclude_modern_count)
	-- 检查候选同盟怪兽是否满足同盟装备的基本规则：它必须是同盟怪兽，且可以通过同盟装备方式装备到目标怪兽身上。
	return aux.CheckUnionEquip(c,tc,exclude_modern_count) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION)
		and c:IsLevelBelow(4) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ②效果的发动条件与对象设定函数：确认本卡处于装备状态且有装备过的怪兽，卡组中存在符合条件的同盟怪兽后，把这张卡装备过的怪兽设为效果对象，并登记操作信息为装备。
function c99249638.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 计算当前这张卡是否正作为同盟装备存在：如果是则 exct=1，用于后续检索时排除同盟怪兽数量限制的额外计数，避免违反新大师规则下同盟怪兽的装备数量限制。
		local exct=aux.IsUnionState(e) and 1 or 0
		return c:GetEquipTarget()
			-- 检查卡组中是否存在至少1只满足 refilter 条件的同盟怪兽，以此作为②效果能否发动的条件之一。
			and Duel.IsExistingMatchingCard(c99249638.refilter,tp,LOCATION_DECK,0,1,nil,c:GetEquipTarget(),tp,exct)
	end
	local tc=e:GetLabelObject()
	-- 将这张卡装备过的怪兽设为该效果的对象，使效果正式取该怪兽为对象。
	Duel.SetTargetCard(tc)
	-- 登记操作信息：声明本效果包含装备卡操作，涉及对象为已确定的装备怪兽，数量为1，供其他卡的效果检测或对应。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,tc,1,0,0)
end
-- ②效果的实际处理函数：从卡组选择1只符合条件的同盟怪兽，将其装备给对象怪兽，并让该同盟怪兽获得同盟装备状态。
function c99249638.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时设置的对象，即这张卡曾经装备过的那只怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然表侧表示且没有脱离效果关系，同时自己魔陷区存在可以放置装备卡的空位，否则不进行装备处理。
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 向玩家显示“请选择要装备的卡”的选卡提示，要求从卡组中选择同盟怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从卡组中选出1只满足条件的同盟怪兽。
		local g=Duel.SelectMatchingCard(tp,c99249638.refilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp,nil)
		local ec=g:GetFirst()
		-- 若成功选到同盟怪兽且能将其装备给对象怪兽，则继续执行同盟状态赋予处理。
		if ec and Duel.Equip(tp,ec,tc) then
			-- 为被装备的同盟怪兽设置同盟状态，使其获得作为装备卡时的代破效果和解除装备特殊召唤等同盟怪兽共有能力。
			aux.SetUnionState(ec)
		end
	end
end
