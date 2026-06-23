--覇王眷竜スターヴ・ヴェノム
-- 效果：
-- 暗属性灵摆怪兽×2
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己场上的上记的卡解放的场合可以从额外卡组特殊召唤。
-- ①：1回合1次，以这张卡以外的自己或对方的场上·墓地1只怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。这个回合，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c43387895.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要2个满足条件的暗属性灵摆怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c43387895.ffilter,2,false)
	-- 添加接触融合特殊召唤规则，通过解放自己场上的卡从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 这张卡只能通过融合召唤特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c43387895.splimit)
	c:RegisterEffect(e1)
	-- 1回合1次，以这张卡以外的自己或对方的场上·墓地1只怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。这个回合，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
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
-- 过滤函数，用于筛选暗属性且为灵摆类型的怪兽
function c43387895.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_PENDULUM)
end
-- 特殊召唤限制函数，确保只能通过融合召唤
function c43387895.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 复制效果的费用，只能发动一次，通过注册标志位实现
function c43387895.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(43387895)==0 end
	e:GetHandler():RegisterFlagEffect(43387895,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 复制效果的目标过滤函数，筛选场上或墓地的怪兽
function c43387895.copyfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 选择目标怪兽，从自己或对方的场上·墓地选择一只怪兽作为复制对象
function c43387895.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c43387895.copyfilter(chkc) and chkc~=c end
	-- 判断是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c43387895.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,c) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽，从场上或墓地选择一只怪兽
	Duel.SelectTarget(tp,c43387895.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,c)
end
-- 执行复制效果，将目标怪兽的卡名和效果复制到自身
function c43387895.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE)) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 将自身卡名更改为目标怪兽的原始卡名
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
		-- 设置结束阶段自动恢复原状的效果
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
	-- 设置贯穿伤害效果，使自身攻击时无视守备力
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册贯穿伤害效果到玩家场上
	Duel.RegisterEffect(e2,tp)
end
-- 结束阶段恢复原状的处理函数
function c43387895.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家已选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
