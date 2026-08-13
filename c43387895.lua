--覇王眷竜スターヴ・ヴェノム
-- 效果：
-- 暗属性灵摆怪兽×2
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上的上记的卡解放的场合可以从额外卡组特殊召唤。
-- ①：1回合1次，以这张卡以外的自己或对方的场上·墓地1只怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。这个回合，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c43387895.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以2只暗属性灵摆怪兽为融合素材（对应“暗属性灵摆怪兽×2”）。
	aux.AddFusionProcFunRep(c,c43387895.ffilter,2,false)
	-- 添加接触融合手续：把自己场上可解放的怪兽作为素材，通过解放这些素材从额外卡组特殊召唤（对应“把自己场上的上记的卡解放的场合可以从额外卡组特殊召唤”）。
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c43387895.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以这张卡以外的自己或对方的场上·墓地1只怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。这个回合，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43387895,0))  --"复制效果"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c43387895.copycost)
	e3:SetTarget(c43387895.copytg)
	e3:SetOperation(c43387895.copyop)
	c:RegisterEffect(e3)
end
-- 定义融合素材过滤函数：素材必须是暗属性且为灵摆怪兽（用于满足“暗属性灵摆怪兽×2”的融合素材要求）。
function c43387895.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_PENDULUM)
end
-- 定义特殊召唤条件限制：仅当召唤方式为融合召唤时允许特殊召唤（排除其他非融合/接触融合的召唤方式）。
function c43387895.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 定义复制效果的发动代价：若本卡在本回合尚未发动过该效果（1回合1次限制），则支付代价并设置标志位，记录已发动。
function c43387895.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(43387895)==0 end
	e:GetHandler():RegisterFlagEffect(43387895,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 定义复制效果可选择的怪兽条件：必须是怪兽且不是衍生物，并且是表侧表示或在墓地。
function c43387895.copyfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 定义复制效果的目标选择处理：从自己或对方的场上·墓地选择1只除自身外满足copyfilter的怪兽作为对象，并完成合法性检查、存在检查和选择动作。
function c43387895.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c43387895.copyfilter(chkc) and chkc~=c end
	-- 发动合法性检查：确认自己或对方的场上·墓地存在至少1只满足copyfilter且不是本卡的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43387895.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,c) end
	-- 向操作者显示“请选择表侧表示的卡”的选择提示，用于目标选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作者从自己或对方的场上·墓地选择1只满足copyfilter且不是本卡的怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c43387895.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,c)
end
-- 定义复制效果处理：若对象仍合法，则将本卡卡名变为对象原本卡名，并复制对象的效果（陷阱怪兽除外）；随后注册结束阶段的重置效果；最后给予本卡控制者场上的怪兽贯穿战斗伤害。
function c43387895.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得复制效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE)) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		-- 直到结束阶段（复制效果只持续到结束阶段，结束阶段结束时解除）。
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(43387895,1))  --"结束复制效果"
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetLabelObject(e1)
		e3:SetLabel(cid)
		e3:SetOperation(c43387895.rstop)
		c:RegisterEffect(e3)
	end
	-- 这个回合，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将贯穿伤害效果注册到场上，使发动者场上的怪兽本回合获得贯穿能力（攻击守备表示怪兽时造成攻击力超过守备力的战斗伤害）。
	Duel.RegisterEffect(e2,tp)
end
-- 结束阶段处理：清除本回合复制的卡名与效果，并触发复制效果结束的提示。
function c43387895.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 手动展示这张卡，用于让双方看到复制效果结束/卡片状态恢复。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家发送“对方选择了：结束复制效果”的提示，告知复制效果已解除。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
