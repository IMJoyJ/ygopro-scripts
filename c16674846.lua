--スピリット・フォース
-- 效果：
-- 对方回合的战斗伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0。那之后，可以把自己墓地存在的1只守备力1500以下的战士族调整加入手卡。
function c16674846.initial_effect(c)
	-- 效果发动条件设置为对方回合的战斗伤害计算时
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c16674846.condition)
	e1:SetOperation(c16674846.operation)
	c:RegisterEffect(e1)
end
-- 判断是否为对方回合且己方受到战斗伤害
function c16674846.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是使用者且使用者受到战斗伤害
	return Duel.GetTurnPlayer()~=tp and Duel.GetBattleDamage(tp)>0
end
-- 过滤满足条件的卡片：守备力1500以下、调整、战士族且可加入手卡
function c16674846.filter(c)
	return c:IsDefenseBelow(1500) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_WARRIOR)
		and c:IsAbleToHand()
end
-- 创建并注册一个使使用者不会受到战斗伤害的效果，并检索满足条件的墓地卡片
function c16674846.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使使用者在本次战斗中不会受到战斗伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果注册给使用者
	Duel.RegisterEffect(e1,tp)
	-- 检索满足条件的墓地卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16674846.filter),tp,LOCATION_GRAVE,0,nil)
	-- 若存在满足条件的卡片且使用者选择发动效果
	if g:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(16674846,0)) then  --"是否要把墓地的1只守备力1500以下的战士族调整加入手卡？"
		-- 提示使用者选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片送入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
