--グリーディー・ヴェノム・フュージョン・ドラゴン
-- 效果：
-- 「捕食植物」怪兽＋原本等级是8星以上的暗属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。
-- ②：这张卡被破坏送去墓地的场合发动。场上的怪兽全部破坏。那之后，可以把自己墓地1只8星以上的暗属性怪兽除外把这张卡从墓地特殊召唤。
function c51570882.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足「捕食植物」属性和等级8星以上的暗属性怪兽作为融合素材
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
-- 过滤满足等级8星以上且为暗属性的怪兽卡片
function c51570882.ffilter2(c)
	return c:GetOriginalLevel()>=8 and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
-- 设置特殊召唤条件，限制只能通过融合召唤方式特殊召唤
function c51570882.splimit(e,se,sp,st)
	-- 若不是在额外卡组则必须使用融合召唤方式召唤
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 筛选可以被无效化的怪兽，包括攻击力大于0或符合无效化条件的表侧表示怪兽
function c51570882.disfilter(c)
	-- 判断目标怪兽是否为表侧表示且攻击力大于0或可被无效化
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 设置效果目标选择函数，选择场上满足条件的怪兽作为对象
function c51570882.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51570882.disfilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c51570882.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效化的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c51570882.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行效果操作，使目标怪兽攻击力归零并使其效果无效
function c51570882.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 设置目标怪兽的攻击力为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 使目标怪兽的效果在回合结束时被无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 判断该卡是否因破坏而进入墓地
function c51570882.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 设置效果目标，准备将场上所有怪兽破坏
function c51570882.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上的所有怪兽作为目标组
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 设置操作信息，记录将要破坏场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 筛选满足暗属性且等级8星以上的可除外怪兽
function c51570882.rmfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(8) and c:IsAbleToRemove()
end
-- 执行效果操作，破坏场上所有怪兽并判断是否可以特殊召唤自身
function c51570882.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有怪兽作为目标组
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	-- 破坏场上所有怪兽，若无成功则返回
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	-- 获取玩家墓地中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c51570882.rmfilter,tp,LOCATION_GRAVE,0,c)
	-- 检查是否有满足条件的墓地怪兽且场上存在召唤空间
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否发动特殊召唤效果
		and Duel.SelectYesNo(tp,aux.Stringid(51570882,2)) then  --"是否把「强欲毒融合龙」特殊召唤？"
		-- 中断当前连锁处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽从墓地除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		-- 将自身从墓地特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
