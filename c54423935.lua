--R・R・R
-- 效果：
-- 这张卡在规则上也当作「急袭猛禽」卡使用。
-- ①：以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从卡组特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方不能把作为对象的怪兽作为攻击对象，也不能作为效果的对象。
function c54423935.initial_effect(c)
	-- ①：以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从卡组特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方不能把作为对象的怪兽作为攻击对象，也不能作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c54423935.target)
	e1:SetOperation(c54423935.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「急袭猛禽」怪兽，且卡组中存在同名怪兽可以特殊召唤
function c54423935.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xba)
		-- 检查卡组中是否存在可以特殊召唤的同名怪兽
		and Duel.IsExistingMatchingCard(c54423935.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤卡组中与指定卡同名且可以特殊召唤的怪兽
function c54423935.spfilter(c,e,tp,cd)
	return c:IsCode(cd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空格、选择对象、设置操作信息）
function c54423935.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsCode(e:GetLabel()) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的「急袭猛禽」怪兽作为对象
		and Duel.IsExistingTarget(c54423935.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「急袭猛禽」怪兽作为对象
	local g=Duel.SelectTarget(tp,c54423935.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置当前连锁的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理（特殊召唤同名怪兽，并为对象怪兽添加不能成为攻击和效果对象的抗性）
function c54423935.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只与对象怪兽同名的怪兽
		local g=Duel.SelectMatchingCard(tp,c54423935.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		local sc=g:GetFirst()
		-- 将选择的怪兽在自己场上表侧表示特殊召唤，若特殊召唤成功则进行后续处理
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方不能把作为对象的怪兽作为攻击对象
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
			e1:SetLabelObject(sc)
			e1:SetLabel(sc:GetFieldID())
			e1:SetCondition(c54423935.imcon)
			-- 设置不能成为攻击对象的效果参数（不会成为攻击对象）
			e1:SetValue(aux.imval1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			-- 设置不能成为对方卡片效果对象的效果参数（不会成为对方效果的对象）
			e2:SetValue(aux.tgoval)
			tc:RegisterEffect(e2)
		end
	end
end
-- 检查特殊召唤的怪兽是否在自己场上表侧表示存在，作为抗性效果的适用条件
function c54423935.imcon(e)
	local tp=e:GetHandlerPlayer()
	local sc=e:GetLabelObject()
	return sc and sc:GetFieldID()==e:GetLabel() and sc:IsFaceup() and sc:IsLocation(LOCATION_MZONE)
		and sc:IsControler(tp)
end
