--魔術の呪文書
-- 效果：
-- 「黑魔术师」「黑魔术少女」才能装备。装备怪兽的攻击力上升700。这张卡从场上送去墓地时，自己回复1000基本分。
function c67227834.initial_effect(c)
	-- 在卡片中注册记载了「黑魔术师」和「黑魔术少女」的卡片密码
	aux.AddCodeList(c,46986414,38033121)
	-- 「黑魔术师」「黑魔术少女」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c67227834.target)
	e1:SetOperation(c67227834.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 「黑魔术师」「黑魔术少女」才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c67227834.eqlimit)
	c:RegisterEffect(e3)
	-- 这张卡从场上送去墓地时，自己回复1000基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67227834,0))  --"LP回复"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c67227834.reccon)
	e4:SetTarget(c67227834.rectg)
	e4:SetOperation(c67227834.recop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给「黑魔术师」或「黑魔术少女」
function c67227834.eqlimit(e,c)
	return c:IsCode(46986414,38033121)
end
-- 过滤条件：场上表侧表示的「黑魔术师」或「黑魔术少女」
function c67227834.filter(c)
	return c:IsFaceup() and c:IsCode(46986414,38033121)
end
-- 装备魔法卡发动时的效果目标选择与处理
function c67227834.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c67227834.filter(chkc) end
	-- 检查场上是否存在可以装备的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c67227834.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c67227834.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理（执行装备）
function c67227834.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 回复效果的发动条件：这张卡从场上送去墓地
function c67227834.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 回复效果的目标选择与处理
function c67227834.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复效果的对象玩家为当前玩家（自己）
	Duel.SetTargetPlayer(tp)
	-- 设置回复效果的参数为1000基本分
	Duel.SetTargetParam(1000)
	-- 设置效果处理信息：使自己回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 回复效果的实际处理
function c67227834.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取回复效果的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分的效果处理
	Duel.Recover(p,d,REASON_EFFECT)
end
