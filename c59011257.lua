--フォーリンチーター
-- 效果：
-- ①：这张卡只要在怪兽区域存在，不能解放，也不能作为融合·同调·超量·连接召唤的素材。
-- ②：这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合，以那之内的1只为对象发动。这张卡的控制权移给作为对象的怪兽的控制者。这只怪兽表侧表示存在期间，作为对象的怪兽不能解放，也不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 注册卡片效果：①效果（自身在怪兽区域存在时不能解放、不能作为融合/同调/超量/连接素材）与②效果（对方特殊召唤怪兽时强制发动，转移控制权并限制对象怪兽的解放与素材用途）。
function s.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不能解放
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(s.fuslimit)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e6)
	-- 注册一个合并的延迟事件监听器，用于检测对方场上有怪兽特殊召唤成功的场合。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ②：这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合，以那之内的1只为对象发动。这张卡的控制权移给作为对象的怪兽的控制者。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))  --"转移控制权"
	e7:SetCategory(CATEGORY_CONTROL)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(custom_code)
	e7:SetCondition(s.ctcon)
	e7:SetTarget(s.cttg)
	e7:SetOperation(s.ctop)
	c:RegisterEffect(e7)
end
-- 限制素材用途的辅助函数，用于判断召唤类型是否为融合召唤。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 过滤对方场上的怪兽。
function s.filter(c,e,tp)
	return c:IsControler(1-tp)
end
-- 效果发动条件：特殊召唤成功的怪兽中存在对方场上的怪兽。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,nil,tp)
end
-- 过滤合法的效果对象：必须是本次特殊召唤的对方怪兽，且自身（这张卡）的控制权可以转移。
function s.indfilter(c,g,tp,ec)
	return c:IsControler(1-tp) and g:IsContains(c) and ec:IsControlerCanBeChanged()
end
-- 效果发动时的目标选择与操作信息设置：选择1只特殊召唤的对方怪兽作为对象，并设置转移控制权的操作信息。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and eg:IsContains(chkc) and c:IsControlerCanBeChanged() end
	if chk==0 then return true end
	-- 玩家选择对方场上1只本次特殊召唤的怪兽作为效果对象。
	Duel.SelectTarget(tp,s.indfilter,tp,0,LOCATION_MZONE,1,1,nil,eg,tp,c)
	-- 设置当前连锁的操作信息为：将自身（这张卡）的控制权转移。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 效果处理：转移这张卡的控制权给对象怪兽的控制者，并使对象怪兽在自身表侧表示存在期间不能解放、不能作为融合/同调/超量/连接召唤的素材。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		if tc:IsControler(1-tp) then
			-- 将自身（这张卡）的控制权转移给对方（即对象怪兽的控制者）。
			Duel.GetControl(c,1-tp)
		end
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，作为对象的怪兽不能解放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.nrcon)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(s.fuslimit)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e5)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e6)
	end
end
-- 限制效果的持续条件：自身（这张卡）必须持续以该怪兽为对象（即自身在场上表侧表示存在）。
function s.nrcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
