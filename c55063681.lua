--パワー・サプライヤー
-- 效果：
-- 1回合1次，选择自己场上表侧表示存在的1只怪兽才能发动。只要这张卡在自己场上表侧表示存在，选择的怪兽的攻击力上升400。
function c55063681.initial_effect(c)
	-- 1回合1次，选择自己场上表侧表示存在的1只怪兽才能发动。只要这张卡在自己场上表侧表示存在，选择的怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55063681,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c55063681.target)
	e1:SetOperation(c55063681.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的怪兽，且该怪兽不能是已被这张卡作为永续对象（或自身已获得过该效果）的怪兽
function c55063681.filter(c,ec)
	return c:IsFaceup() and ((ec==c and c:GetFlagEffect(55063681)==0) or (ec~=c and not ec:IsHasCardTarget(c)))
end
-- 效果发动的发动准备，检查并选择自己场上1只表侧表示的怪兽作为对象
function c55063681.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c55063681.filter(chkc,e:GetHandler()) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c55063681.filter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c55063681.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler())
end
-- 效果处理：如果对象怪兽和这张卡都在场上表侧表示存在，则使该怪兽的攻击力上升400（若选择其他怪兽则建立永续对象关系，若选择自身则注册标识）
function c55063681.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		if tc~=c then
			c:SetCardTarget(tc)
			-- 只要这张卡在自己场上表侧表示存在，选择的怪兽的攻击力上升400。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(400)
			e1:SetCondition(c55063681.atkcon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		else
			-- 只要这张卡在自己场上表侧表示存在，选择的怪兽的攻击力上升400。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(400)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(55063681,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
-- 攻击力上升效果的持续条件：这张卡（效果来源）依然将对象怪兽作为永续对象
function c55063681.atkcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
