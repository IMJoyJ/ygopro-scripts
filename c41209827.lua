--スターヴ・ヴェノム・フュージョン・ドラゴン
-- 效果：
-- 衍生物以外的场上的暗属性怪兽×2
-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升对方场上1只特殊召唤的怪兽的攻击力数值。
-- ②：1回合1次，以对方场上1只5星以上的怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
-- ③：融合召唤的这张卡被破坏的场合才能发动。对方场上的特殊召唤的怪兽全部破坏。
function c41209827.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的暗属性怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c41209827.ffilter,2,true)
	-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升对方场上1只特殊召唤的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41209827,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c41209827.atkcon)
	e1:SetTarget(c41209827.atktg)
	e1:SetOperation(c41209827.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方场上1只5星以上的怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41209827,1))  --"复制效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c41209827.copycost)
	e2:SetTarget(c41209827.copytg)
	e2:SetOperation(c41209827.copyop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被破坏的场合才能发动。对方场上的特殊召唤的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41209827,2))  --"全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c41209827.descon)
	e3:SetTarget(c41209827.destg)
	e3:SetOperation(c41209827.desop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数，筛选场上暗属性且非衍生物的怪兽
function c41209827.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsOnField() and not c:IsType(TYPE_TOKEN)
end
-- 效果发动条件判断，判断是否为融合召唤
function c41209827.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 攻击力上升效果的目标筛选函数，筛选对方场上特殊召唤且表侧表示的怪兽
function c41209827.atkfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup()
end
-- 效果发动时的处理函数，检查是否存在满足条件的目标怪兽
function c41209827.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41209827.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 攻击力上升效果的处理函数，选择目标怪兽并提升自身攻击力
function c41209827.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectMatchingCard(tp,c41209827.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		-- 设置自身攻击力增加效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 复制效果的费用函数，确保每回合只能发动一次
function c41209827.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(41209827)==0 end
	e:GetHandler():RegisterFlagEffect(41209827,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 复制效果的目标筛选函数，筛选对方场上5星以上且非衍生物的表侧表示怪兽
function c41209827.copyfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and not c:IsType(TYPE_TOKEN)
end
-- 复制效果的目标选择函数，选择满足条件的目标怪兽
function c41209827.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c41209827.copyfilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c41209827.copyfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c41209827.copyfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 复制效果的处理函数，复制目标怪兽的卡名和效果
function c41209827.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 设置自身卡名改变效果
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
		-- 设置结束阶段自动取消复制效果的持续效果
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(41209827,3))  --"结束复制效果"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c41209827.rstop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 结束复制效果的处理函数，重置复制的卡名和效果
function c41209827.rstop(e,tp,eg,ep,ev,re,r,rp)
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
	-- 提示对方玩家选择发动了什么效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 破坏效果的发动条件判断，判断是否为融合召唤且在主要怪兽区被破坏
function c41209827.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 破坏效果的目标筛选函数，筛选对方场上特殊召唤的怪兽
function c41209827.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 破坏效果的目标选择函数，检查是否存在满足条件的目标怪兽
function c41209827.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41209827.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的目标怪兽组
	local g=Duel.GetMatchingGroup(c41209827.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，记录将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理函数，破坏满足条件的怪兽
function c41209827.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的目标怪兽组
	local g=Duel.GetMatchingGroup(c41209827.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 将目标怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
