--炎霊神パイロレクス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的炎属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，双方玩家受到那只怪兽的原本攻击力一半数值的伤害。
-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
function c35842855.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的炎属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c35842855.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，双方玩家受到那只怪兽的原本攻击力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35842855,0))  --"破坏并伤害"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,35842855)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c35842855.destg)
	e3:SetOperation(c35842855.desop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c35842855.leaveop)
	c:RegisterEffect(e4)
end
-- 判断特殊召唤条件是否满足，即场上是否有空位且己方墓地有5只炎属性怪兽。
function c35842855.spcon(e,c)
	if c==nil then return true end
	-- 判断己方场上是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判断己方墓地是否有5只炎属性怪兽。
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_FIRE)==5
end
-- 设置效果目标，选择对方场上一只怪兽作为破坏对象。
function c35842855.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否有符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只怪兽作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，将破坏效果加入连锁。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，将伤害效果加入连锁。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 执行破坏和伤害效果，对目标怪兽进行破坏并造成双方伤害。
function c35842855.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且被破坏成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)==1 then
		local atk=math.floor(tc:GetTextAttack()/2)
		if atk>0 then
			-- 给发动者造成目标怪兽原本攻击力一半的伤害。
			Duel.Damage(tp,atk,REASON_EFFECT,true)
			-- 给对方玩家造成目标怪兽原本攻击力一半的伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT,true)
			-- 完成伤害处理时点。
			Duel.RDComplete()
		end
	end
end
-- 设置并注册战斗阶段跳过效果。
function c35842855.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 创建并注册战斗阶段跳过效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合玩家是否为该卡的控制者。
	if Duel.GetTurnPlayer()==effp then
		-- 记录当前回合数用于条件判断。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c35842855.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 将战斗阶段跳过效果注册给控制者。
	Duel.RegisterEffect(e1,effp)
end
-- 判断是否跳过战斗阶段的条件函数。
function c35842855.skipcon(e)
	-- 判断当前回合数是否与记录的回合数不同。
	return Duel.GetTurnCount()~=e:GetLabel()
end
