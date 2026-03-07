--紫炎の寄子
-- 效果：
-- 自己场上存在的名字带有「六武众」的怪兽进行战斗的场合，那次伤害计算时把这张卡从手卡送去墓地发动。那只怪兽在这个回合不会被战斗破坏。
function c33883834.initial_effect(c)
	-- 效果原文内容：自己场上存在的名字带有「六武众」的怪兽进行战斗的场合，那次伤害计算时把这张卡从手卡送去墓地发动。那只怪兽在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33883834,0))  --"不被战斗破坏"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c33883834.con)
	e1:SetCost(c33883834.cost)
	e1:SetOperation(c33883834.op)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件，即攻击怪兽或防守怪兽是「六武众」，且该玩家未发动过此效果
function c33883834.con(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 效果作用：获取当前防守怪兽
	local d=Duel.GetAttackTarget()
	return d and ((a:IsControler(tp) and a:IsSetCard(0x103d)) or (d:IsControler(tp) and d:IsSetCard(0x103d)))
		-- 效果作用：确保该玩家在本次伤害计算中未发动过此效果
		and Duel.GetFlagEffect(tp,33883834)==0
end
-- 效果作用：设置发动此效果的代价，将自身送去墓地并注册标识效果
function c33883834.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 效果作用：将自身从手牌送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	-- 效果作用：为使用者注册一个在伤害计算阶段结束时重置的标识效果，防止重复发动
	Duel.RegisterFlagEffect(tp,33883834,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果作用：设置效果发动后的处理，为攻击或防守的「六武众」怪兽赋予不被战斗破坏的效果
function c33883834.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 效果作用：获取当前防守怪兽
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	-- 效果原文内容：那只怪兽在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	if a:IsControler(tp) then
		a:RegisterEffect(e1)
	else
		d:RegisterEffect(e1)
	end
end
