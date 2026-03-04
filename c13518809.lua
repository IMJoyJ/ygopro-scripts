--破滅の美神ルイン
-- 效果：
-- 「世界不灭」降临
-- ①：这张卡的卡名只要在手卡·场上存在当作「破灭之女神 露茵」使用。
-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己场上的仪式怪兽不会被效果破坏。
-- ③：只使用仪式怪兽作仪式召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ④：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c13518809.initial_effect(c)
	c:EnableReviveLimit()
	-- 使该卡在手牌和场上时视为「破灭之女神 露茵」使用
	aux.EnableChangeCode(c,46427957,LOCATION_MZONE+LOCATION_HAND)
	-- 只要仪式召唤的这张卡在怪兽区域存在，自己场上的仪式怪兽不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c13518809.indcon)
	e2:SetTarget(c13518809.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 只使用仪式怪兽作仪式召唤的这张卡在同1次的战斗阶段中可以作2次攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(c13518809.condition)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力数值的伤害
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测该卡是否与对方怪兽战斗
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(c13518809.damtg)
	e4:SetOperation(c13518809.damop)
	c:RegisterEffect(e4)
	-- 仪式召唤成功时触发，用于标记是否使用仪式怪兽作为素材
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c13518809.matcon)
	e5:SetOperation(c13518809.matop)
	c:RegisterEffect(e5)
	-- 检查该卡的仪式召唤所使用的素材是否全部为仪式怪兽
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(c13518809.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
-- 判断该卡是否为仪式召唤
function c13518809.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 判断目标怪兽是否为仪式怪兽
function c13518809.indtg(e,c)
	return c:IsType(TYPE_RITUAL)
end
-- 过滤非仪式怪兽的素材
function c13518809.mfilter(c)
	return not c:IsType(TYPE_RITUAL)
end
-- 判断该卡是否满足额外攻击条件
function c13518809.condition(e)
	return e:GetHandler():GetFlagEffect(13518809)>0
end
-- 设置伤害效果的目标玩家和伤害值
function c13518809.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置连锁处理中伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理中伤害效果的目标伤害值为对方怪兽的攻击力
	Duel.SetTargetParam(atk)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 执行伤害效果的处理函数
function c13518809.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断该卡是否为仪式召唤且使用了仪式怪兽作为素材
function c13518809.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 为该卡注册一个标志位，表示已满足额外攻击条件
function c13518809.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(13518809,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 检查该卡的召唤所使用的素材是否全部为仪式怪兽
function c13518809.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c13518809.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
