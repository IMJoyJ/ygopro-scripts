--慧眼の魔術師
-- 效果：
-- ←5 【灵摆】 5→
-- ①：另一边的自己的灵摆区域有「魔术师」卡或「娱乐伙伴」卡存在的场合才能发动。这张卡破坏，从卡组把「慧眼之魔术师」以外的1只「魔术师」灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- ①：把这张卡从手卡丢弃，以自己的灵摆区域1张灵摆刻度和原本数值不同的卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成原本数值。
function c72714461.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「魔术师」卡或「娱乐伙伴」卡存在的场合才能发动。这张卡破坏，从卡组把「慧眼之魔术师」以外的1只「魔术师」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c72714461.pencon)
	e2:SetTarget(c72714461.pentg)
	e2:SetOperation(c72714461.penop)
	c:RegisterEffect(e2)
	-- ①：把这张卡从手卡丢弃，以自己的灵摆区域1张灵摆刻度和原本数值不同的卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成原本数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72714461,1))  --"改变灵摆刻度"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c72714461.sccost)
	e3:SetTarget(c72714461.sctg)
	e3:SetOperation(c72714461.scop)
	c:RegisterEffect(e3)
end
-- 过滤条件：是否为「魔术师」卡或「娱乐伙伴」卡
function c72714461.cfilter(c)
	return c:IsSetCard(0x98,0x9f)
end
-- 灵摆效果发动条件：检查另一边的自己的灵摆区域是否存在「魔术师」卡或「娱乐伙伴」卡
function c72714461.pencon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在除自身以外的「魔术师」卡或「娱乐伙伴」卡
	return Duel.IsExistingMatchingCard(c72714461.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤条件：卡组中「慧眼之魔术师」以外的「魔术师」灵摆怪兽，且不能被禁止放置
function c72714461.penfilter(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM) and not c:IsCode(72714461) and not c:IsForbidden()
end
-- 灵摆效果发动准备：检查自身是否可破坏，以及卡组中是否存在可放置的「魔术师」灵摆怪兽
function c72714461.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查卡组中是否存在满足条件的「魔术师」灵摆怪兽
		and Duel.IsExistingMatchingCard(c72714461.penfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果处理：破坏自身，并从卡组选择1只「魔术师」灵摆怪兽放置到自己的灵摆区域
function c72714461.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试因效果破坏自身，若成功破坏则继续处理
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1张满足条件的「魔术师」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c72714461.penfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽以表侧表示放置到自己的灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 怪兽效果发动代价：检查是否能丢弃，并将此卡从手卡丢弃送去墓地
function c72714461.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将手卡的这张卡丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD+REASON_COST)
end
-- 过滤条件：当前左灵摆刻度与原本左灵摆刻度不同的卡
function c72714461.scfilter(c)
	return c:GetLeftScale()~=c:GetOriginalLeftScale()
end
-- 怪兽效果发动准备：选择自己灵摆区域1张灵摆刻度和原本数值不同的卡作为对象
function c72714461.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c72714461.scfilter(chkc) end
	-- 检查自己灵摆区域是否存在灵摆刻度与原本数值不同的卡
	if chk==0 then return Duel.IsExistingTarget(c72714461.scfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1张灵摆刻度与原本数值不同的卡作为效果对象
	Duel.SelectTarget(tp,c72714461.scfilter,tp,LOCATION_PZONE,0,1,1,nil)
end
-- 怪兽效果处理：使作为对象的卡的灵摆刻度直到回合结束时变成原本数值
function c72714461.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那张卡的灵摆刻度直到回合结束时变成原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(tc:GetOriginalLeftScale())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(tc:GetOriginalRightScale())
		tc:RegisterEffect(e2)
	end
end
