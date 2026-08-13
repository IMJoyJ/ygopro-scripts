--グリーディー・ヴェノム・フュージョン・ドラゴン
-- 效果：
-- 「捕食植物」怪兽＋原本等级是8星以上的暗属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。
-- ②：这张卡被破坏送去墓地的场合发动。场上的怪兽全部破坏。那之后，可以把自己墓地1只8星以上的暗属性怪兽除外把这张卡从墓地特殊召唤。
function c51570882.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「捕食植物」怪兽和1只原本等级8星以上的暗属性怪兽作为融合素材，可进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),c51570882.ffilter2,true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c51570882.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51570882,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c51570882.distg)
	e2:SetOperation(c51570882.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏送去墓地的场合发动。场上的怪兽全部破坏。那之后，可以把自己墓地1只8星以上的暗属性怪兽除外把这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51570882,1))  --"全部破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c51570882.spcon)
	e3:SetTarget(c51570882.sptg)
	e3:SetOperation(c51570882.spop)
	c:RegisterEffect(e3)
end
-- 定义第二只融合素材的筛选条件：该怪兽的原本等级必须为8星以上，且属性为暗属性。
function c51570882.ffilter2(c)
	return c:GetOriginalLevel()>=8 and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
-- 定义此卡的特殊召唤限制：若此卡在额外卡组，则只允许通过融合召唤的方式特殊召唤；若不在额外卡组（如墓地）则不受此限制。
function c51570882.splimit(e,se,sp,st)
	-- 判断当前特殊召唤行为是否被允许：若此卡不在额外卡组则直接允许；若在额外卡组，则必须是以融合召唤方式（aux.fuslimit检查）进行。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 定义①效果的取对象筛选条件：对象需为表侧表示怪兽，且当前攻击力大于0，或是可被无效效果的效果怪兽。
function c51570882.disfilter(c)
	-- 具体筛选：怪兽必须表侧表示，并且攻击力大于0，或者可以通过aux.NegateMonsterFilter判定为可被无效效果的效果怪兽。
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- ①效果发动时的目标选择处理：检查场上是否存在满足条件的怪兽，若有则提示玩家选择1只，将其登记为对象，并设置操作信息为无效化处理。
function c51570882.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51570882.disfilter(chkc) end
	-- 在效果发动时判定：场上是否存在至少1只满足disfilter条件的表侧表示怪兽可作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51570882.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示“请选择要无效的卡”，用于打开选择卡片界面时的说明。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从双方怪兽区域选择1只满足条件的表侧表示怪兽作为效果对象，同时自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c51570882.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为CATEGORY_DISABLE，处理对象为已选择的1只怪兽，数量为1，用于让其他卡/效果能够检测到本次有“无效”操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果的处理：取对象怪兽，若其仍表侧表示且与效果关联，则赋予其攻击力变为0、效果无效化、怪兽效果无效化三个效果，直到回合结束。
function c51570882.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁中取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到回合结束时，那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- ②效果的发动条件：判断此卡是否因被破坏而被送去墓地（即进入墓地的原因是破坏）。
function c51570882.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- ②效果的发动时点目标设定：必发效果，先取得场上所有怪兽，并登记破坏所有怪兽的操作信息。
function c51570882.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方怪兽区域的全部怪兽，组成将被破坏的卡组。
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 设置当前连锁的操作信息：本次效果包含“破坏”处理，对象为场上全部怪兽，数量为dg:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 定义墓地除外素材的筛选条件：该卡必须为暗属性、等级8星以上，且可以被除外。
function c51570882.rmfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(8) and c:IsAbleToRemove()
end
-- ②效果的处理：先破坏场上所有怪兽；若破坏成功且自己场上有空位、此卡在墓地且可特殊召唤，则询问玩家是否除外1只符合条件的怪兽；选择后除外该怪兽并将此卡从墓地特殊召唤。
function c51570882.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方怪兽区域的全部怪兽，作为破坏的对象。
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 以效果破坏场上所有怪兽；若实际破坏数量为0，则结束效果，不进行后续特殊召唤。
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	-- 从自己的墓地筛选出满足除外条件的怪兽（暗属性、8星以上、可除外），作为特殊召唤此卡时除外的候选集合。
	local g=Duel.GetMatchingGroup(c51570882.rmfilter,tp,LOCATION_GRAVE,0,c)
	-- 判断后续特殊召唤是否可行：存在可除外的候选卡，并且自己主要怪兽区有空位。
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否选择发动“将墓地此卡特殊召唤”的后续处理，只有选“是”才继续。
		and Duel.SelectYesNo(tp,aux.Stringid(51570882,2)) then  --"是否把「强欲毒融合龙」特殊召唤？"
		-- 中断当前效果链，使此后的处理视为另一个时点，避免与之前的破坏处理错开时点。
		Duel.BreakEffect()
		-- 向玩家发送选择提示“请选择要除外的卡”，用于选择墓地除外的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g:Select(tp,1,1,nil)
		-- 将玩家选择的1张卡表侧表示除外，作为特殊召唤此卡的代价。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		-- 将此卡从墓地以表侧攻击表示特殊召唤到玩家场上的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
