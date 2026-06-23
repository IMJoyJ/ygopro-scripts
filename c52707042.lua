--リブロマンサー・ミスティガール
-- 效果：
-- 「书灵师」卡降临。这个卡名的②的效果1回合只能使用1次。
-- ①：只要使用场上的怪兽作仪式召唤的这张卡在怪兽区域存在，自己场上的仪式怪兽不会成为对方怪兽的效果的对象。
-- ②：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 注册卡片效果：e1为仪式素材检查，e2为使用场上怪兽仪式召唤的此卡在场时使自己场上的仪式怪兽获得对方怪兽效果对象抗性，e3为特殊召唤成功时使对方场上1只表侧表示怪兽攻击力变为0且效果无效
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：只要使用场上的怪兽作仪式召唤的这张卡在怪兽区域存在
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- ①：只要使用场上的怪兽作仪式召唤的这张卡在怪兽区域存在，自己场上的仪式怪兽不会成为对方怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.matcon)
	-- 设置抗性效果的影响对象为仪式怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_RITUAL))
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时攻击力变成0，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 检查仪式召唤的素材中是否包含场上的怪兽，若有则为这张卡注册一个带有客户端提示的标记
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"使用场上的怪兽作仪式召唤"
	end
end
-- 判断此卡是否为仪式召唤登场，且仪式召唤时使用了场上的怪兽作为素材
function s.matcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id)>0
end
-- 限制不能成为效果对象的效果来源为对方玩家发动的怪兽效果
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-e:GetHandlerPlayer()
end
-- 过滤对方场上表侧表示且攻击力大于0或效果未被无效的效果怪兽
function s.filter(c)
	-- 判定卡片是否为表侧表示，且其攻击力大于0或属于可被无效化的效果怪兽
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 效果②的发动准备与对象选择，在发动时以对方场上1只表侧表示怪兽为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 步骤0：判定对方场上是否存在至少1只符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果②的实际处理：使作为对象的怪兽直到回合结束时攻击力变成0，效果无效化
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那只怪兽直到回合结束时攻击力变成0
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
	end
end
