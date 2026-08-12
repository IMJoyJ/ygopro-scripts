--魂源への影劫回帰
-- 效果：
-- ①：以自己场上1只「影依」怪兽为对象才能发动。从手卡把1张「影依」卡送去墓地。作为对象的怪兽攻击力·守备力上升1000，结束阶段变成里侧守备表示。
function c78942513.initial_effect(c)
	-- ①：以自己场上1只「影依」怪兽为对象才能发动。从手卡把1张「影依」卡送去墓地。作为对象的怪兽攻击力·守备力上升1000，结束阶段变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果在伤害步骤中仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c78942513.target)
	e1:SetOperation(c78942513.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「影依」怪兽
function c78942513.filter(c)
	return c:IsSetCard(0x9d) and c:IsFaceup()
end
-- 过滤手卡中可以送去墓地的「影依」卡
function c78942513.tgfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToGrave()
end
-- 效果发动时的对象选择与合法性检测
function c78942513.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c78942513.filter(chkc) end
	-- 检查自己场上是否存在可作为对象的表侧表示「影依」怪兽
	if chk==0 then return Duel.IsExistingTarget(c78942513.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查手卡中是否存在可送去墓地的「影依」卡
		and Duel.IsExistingMatchingCard(c78942513.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「影依」怪兽作为效果对象
	Duel.SelectTarget(tp,c78942513.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置将手卡中的卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c78942513.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1张满足条件的「影依」卡
	local g=Duel.SelectMatchingCard(tp,c78942513.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 若成功将选中的手卡送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 获取发动时选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
			-- 作为对象的怪兽攻击力·守备力上升1000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1000)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(78942513,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 结束阶段变成里侧守备表示。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetCountLimit(1)
			e3:SetLabel(fid)
			e3:SetLabelObject(tc)
			e3:SetCondition(c78942513.flipcon)
			e3:SetOperation(c78942513.flipop)
			-- 注册在结束阶段适用的延迟效果
			Duel.RegisterEffect(e3,tp)
		end
	end
end
-- 检查目标怪兽是否仍带有有效的标记，若已失效则重置该效果
function c78942513.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(78942513)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段将目标怪兽变成里侧守备表示的操作函数
function c78942513.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽改变为里侧守备表示
	Duel.ChangePosition(e:GetLabelObject(),POS_FACEDOWN_DEFENSE)
end
