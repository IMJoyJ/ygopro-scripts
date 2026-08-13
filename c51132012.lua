--大紅蓮魔闘士
-- 效果：
-- 这张卡不能通常召唤。「大红莲魔斗士」1回合1次在让效果怪兽以外的自己墓地最多3只怪兽回到卡组·额外卡组的场合才能从手卡·墓地特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升因为那次特殊召唤而回到卡组的通常怪兽数量×800。
-- ②：1回合1次，以场上1只怪兽和效果怪兽以外的自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽破坏，作为对象的墓地的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：为「大红莲魔斗士」注册三个效果——①不能通常召唤的特殊召唤条件限制；②从手卡·墓地进行的规则特殊召唤手续（将效果怪兽以外的自己墓地最多3只怪兽返回卡组·额外卡组）；③1回合1次以场上1只怪兽和自己墓地1只非效果怪兽为对象的起动效果（破坏场上怪兽并特殊召唤墓地怪兽）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这段效果对应原文：‘这张卡不能通常召唤。’（作为召唤限制条件，仅在规则特殊召唤手续之外不允许通常召唤）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 这段效果对应原文：‘「大红莲魔斗士」1回合1次在让效果怪兽以外的自己墓地最多3只怪兽回到卡组·额外卡组的场合才能从手卡·墓地特殊召唤。’（1回合1次的规则召唤手续，进行代价返回并从手卡/墓地特殊召唤）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spscon)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
	-- 这段效果对应原文：‘②：1回合1次，以场上1只怪兽和效果怪兽以外的自己墓地1只怪兽为对象才能发动。作为对象的场上的怪兽破坏，作为对象的墓地的怪兽特殊召唤。’
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏并特殊召唤"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 定义代价过滤条件：该怪兽必须是非效果怪兽、是怪兽，并且可以作为代价返回卡组或额外卡组。
function s.cfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- 特殊召唤手续的发动条件：当用于规则询问时直接允许；实际召唤时判断自己墓地存在1~3只符合条件的非效果怪兽，并且自己主要怪兽区有空位。
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中除这张卡自身以外的所有满足代价条件的非效果怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	-- 检查自己场上是否至少有1个可用的主要怪兽区域，否则无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 检查上述可选怪兽组中是否存在数量为1到3的子组，即能否选择1~3只怪兽作为返回卡组的代价。
	local res=g:CheckSubGroup(aux.TRUE,1,3)
	return res
end
-- 特殊召唤手续的发动时选择处理：从自己墓地中选择1~3只符合条件的非效果怪兽作为返回卡组的代价，并将选择结果保存到效果中。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取自己墓地中符合条件的非效果怪兽，供玩家选择作为代价。
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	-- 弹出选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从可选怪兽中选择1到3张作为返回卡组的代价（无条件，只需满足数量）。
	local sg=mg:SelectSubGroup(tp,aux.TRUE,true,1,3)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：将选定的怪兽返回持有者卡组并洗牌，统计其中通常怪兽数量，给特殊召唤成功的这张卡赋予攻击力上升效果。
function s.spsop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gg>0 then
		-- 手动为返回卡组的怪兽显示被选中的动画，并记录这些卡被选为对象。
		Duel.HintSelection(gg)
	end
	-- 将选定的代价怪兽以特殊召唤为原因送回持有者卡组并洗牌，完成特殊召唤手续。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	local ag=g:Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(Card.IsType,nil,TYPE_NORMAL)
	-- 这段效果对应原文：‘①：这个方法特殊召唤的这张卡的攻击力上升因为那次特殊召唤而回到卡组的通常怪兽数量×800。’（根据返回卡组的通常怪兽数量提升攻击力）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(ag:GetCount()*800)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
-- 场上怪兽作为破坏对象的追加条件：该怪兽被破坏/离开后，自己场上仍有可用的怪兽区域，以保证后续能特殊召唤墓地怪兽。
function s.desfilter(c,tp)
	-- 判断该对象若被破坏或离场后，自己场上是否仍存在可用的怪兽区域。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 墓地怪兽的特殊召唤条件：该怪兽是非效果怪兽，并且可以被当前效果特殊召唤（满足苏生限制与召唤手续）。
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和目标选择阶段：需要场上存在可破坏且破坏后仍有空位的怪兽，并且墓地存在可特殊召唤的非效果怪兽；若满足，则进行选对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 检查场上是否存在至少1只满足条件的对象怪兽：可以作为破坏对象，且其离开后自己仍有怪兽区域可用。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		-- 检查墓地是否存在至少1只非效果怪兽，且可以被这个效果特殊召唤。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果对象（同时将其登记为当前连锁的对象）。
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只非效果怪兽作为效果对象（同时将其登记为当前连锁的对象）。
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将会破坏1张对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息：本次连锁将会特殊召唤1张对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- ②效果的处理：确认两个对象均与效果相关，先破坏场上对象怪兽，若破坏成功且墓地对象仍可特招，则将其特殊召唤到自己场上。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁的两个效果对象：第一个是场上要破坏的怪兽，第二个是墓地要特殊召唤的怪兽。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 若第一个对象仍与效果有联系且是怪兽，则将其破坏（按效果处理）。
	if tc1:IsRelateToEffect(e) and tc1:IsType(TYPE_MONSTER) and Duel.Destroy(tc1,REASON_EFFECT)>0
		-- 并且第二个对象仍与效果有联系，且没有受到王家长眠之谷等不能从墓地特殊召唤的限制。
		and tc2:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc2) then
		-- 将第二个对象以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
