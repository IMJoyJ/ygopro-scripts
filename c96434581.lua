--オーバード・パラディオン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「圣像骑士」怪兽为对象才能发动。这个回合，那只「圣像骑士」怪兽不受自身以外的卡的效果影响。
function c96434581.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「圣像骑士」怪兽为对象才能发动。这个回合，那只「圣像骑士」怪兽不受自身以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,96434581+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c96434581.target)
	e1:SetOperation(c96434581.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「圣像骑士」怪兽
function c96434581.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x116)
end
-- 效果发动的靶向检测与对象选择
function c96434581.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c96434581.filter(chkc) end
	-- 检查场上是否存在可作为对象的表侧表示「圣像骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c96434581.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「圣像骑士」怪兽作为效果对象
	Duel.SelectTarget(tp,c96434581.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使目标怪兽在本回合内获得不受自身以外卡片效果影响的免疫状态
function c96434581.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，那只「圣像骑士」怪兽不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c96434581.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 免疫效果过滤器：判定效果来源是否为自身以外的卡
function c96434581.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
