--タックルセイダー
-- 效果：
-- 这张卡被送去墓地的场合，可以从以下效果选择1个发动。
-- ●选择对方场上表侧表示存在的1只怪兽变成里侧守备表示。
-- ●选择对方场上表侧表示存在的1张魔法·陷阱卡回到持有者手卡。这个回合，对方不能把这个效果回到手卡的卡以及那些同名卡发动。
function c12467005.initial_effect(c)
	-- 创建一个诱发选发效果，当此卡被送去墓地时发动，效果描述为选择效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12467005,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c12467005.target)
	e1:SetOperation(c12467005.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示存在的怪兽，使其可以变成里侧守备表示
function c12467005.filter1(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 过滤对方场上表侧表示存在的魔法·陷阱卡，使其可以回到持有者手卡
function c12467005.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 处理此卡被送去墓地时的效果选择与目标选择
function c12467005.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测对方场上是否存在满足条件的怪兽（表侧表示且可以变成里侧守备表示）
	local b1=Duel.IsExistingTarget(c12467005.filter1,tp,0,LOCATION_MZONE,1,nil)
	-- 检测对方场上是否存在满足条件的魔法·陷阱卡（表侧表示且可以回到手卡）
	local b2=Duel.IsExistingTarget(c12467005.filter2,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 若两个效果都可用，则让玩家选择发动哪个效果，选项为“怪兽变成里侧守备表示”
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(12467005,1),aux.Stringid(12467005,2))  --"怪兽变成里侧守备表示"
	-- 若只有第一个效果可用，则让玩家选择发动第一个效果，选项为“怪兽变成里侧守备表示”
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(12467005,1))  --"怪兽变成里侧守备表示"
	-- 若只有第二个效果可用，则让玩家选择发动第二个效果，选项为“魔法·陷阱卡回到手卡”
	else op=Duel.SelectOption(tp,aux.Stringid(12467005,2))+1 end  --"魔法·陷阱卡回到手卡"
	e:SetLabel(op)
	if op==0 then
		-- 向玩家发送提示消息，提示选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		-- 选择对方场上满足条件的1只怪兽作为目标
		local g=Duel.SelectTarget(tp,c12467005.filter1,tp,0,LOCATION_MZONE,1,1,nil)
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
		-- 设置连锁操作信息，表示此效果将改变目标怪兽的表示形式
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	else
		-- 向玩家发送提示消息，提示选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		-- 选择对方场上满足条件的1张魔法·陷阱卡作为目标
		local g=Duel.SelectTarget(tp,c12467005.filter2,tp,0,LOCATION_ONFIELD,1,1,nil)
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置连锁操作信息，表示此效果将使目标卡回到手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 处理此卡被送去墓地时的效果执行
function c12467005.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		-- 将目标怪兽改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	else
		local code=tc:GetCode()
		-- 将目标魔法·陷阱卡送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 创建一个场地方效果，用于禁止对方在本回合发动与该卡同名的魔法·陷阱卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c12467005.aclimit)
		e1:SetLabel(code)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将创建的场地方效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制对方发动魔法·陷阱卡的函数，用于判断是否为同名卡且为魔法·陷阱卡
function c12467005.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end
