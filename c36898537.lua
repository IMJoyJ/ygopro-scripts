--メタファイズ・ホルス・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合，那些作为同调素材的除调整以外的怪兽种类的以下效果各能发动。
-- ●通常怪兽：这个回合这张卡不受自身以外的卡的效果影响。
-- ●效果怪兽：以这张卡以外的场上1张表侧表示的卡为对象才能发动。那个效果无效。
-- ●灵摆怪兽：对方场上1只怪兽由对方选出，自己得到那个控制权。这个回合那只怪兽不能攻击。
function c36898537.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的怪兽作为同调素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，那些作为同调素材的除调整以外的怪兽种类的以下效果各能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c36898537.valcheck)
	c:RegisterEffect(e1)
	-- ●通常怪兽：这个回合这张卡不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36898537,0))  --"效果耐性"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c36898537.immcon)
	e2:SetOperation(c36898537.immop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ●效果怪兽：以这张卡以外的场上1张表侧表示的卡为对象才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36898537,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c36898537.negcon)
	e3:SetTarget(c36898537.negtg)
	e3:SetOperation(c36898537.negop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	-- ●灵摆怪兽：对方场上1只怪兽由对方选出，自己得到那个控制权。这个回合那只怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36898537,2))  --"得到控制权"
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c36898537.ctcon)
	e4:SetTarget(c36898537.cttg)
	e4:SetOperation(c36898537.ctop)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
end
-- 检查同调召唤所用的素材中除调整外的怪兽类型，并将结果记录在效果标签中
function c36898537.valcheck(e,c)
	local g=c:GetMaterial()
	local tpe=0
	local tc=g:GetFirst()
	while tc do
		if not tc:IsSynchroType(TYPE_TUNER) then
			tpe=bit.bor(tpe,tc:GetSynchroType())
		end
		tc=g:GetNext()
	end
	e:SetLabel(tpe)
end
-- 判断是否使用了通常怪兽作为同调素材
function c36898537.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and bit.band(e:GetLabelObject():GetLabel(),TYPE_NORMAL)~=0
end
-- 使自身在本回合内不受除自身外的卡的效果影响
function c36898537.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个使目标卡不受效果影响的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c36898537.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断效果来源是否为自身以外的卡
function c36898537.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 判断是否使用了效果怪兽作为同调素材
function c36898537.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and bit.band(e:GetLabelObject():GetLabel(),TYPE_EFFECT)~=0
end
-- 过滤条件：选择场上表侧表示且非通常怪兽的卡
function c36898537.negfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_NORMAL)
end
-- 选择场上一张符合条件的卡作为对象
function c36898537.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c36898537.negfilter(chkc) end
	-- 检查是否存在符合条件的场上的卡
	if chk==0 then return Duel.IsExistingTarget(c36898537.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张符合条件的卡作为对象
	local g=Duel.SelectTarget(tp,c36898537.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息为使目标卡效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 使目标卡效果无效并解除其效果
function c36898537.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个使目标卡效果无效的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个使目标卡效果被解除的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否使用了灵摆怪兽作为同调素材
function c36898537.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and bit.band(e:GetLabelObject():GetLabel(),TYPE_PENDULUM)~=0
end
-- 检查对方场上是否存在可改变控制权的怪兽
function c36898537.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可改变控制权的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 选择对方场上一只怪兽并获得其控制权
function c36898537.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方选择一只怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上一只可改变控制权的怪兽
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToChangeControler,1-tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试获得目标怪兽的控制权
	if Duel.GetControl(tc,tp)~=0 then
		-- 若成功获得控制权，则使该怪兽本回合不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
