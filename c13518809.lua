--破滅の美神ルイン
-- 效果：
-- 「世界不灭」降临
-- ①：这张卡的卡名只要在手卡·场上存在当作「破灭之女神 露茵」使用。
-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己场上的仪式怪兽不会被效果破坏。
-- ③：只使用仪式怪兽作仪式召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ④：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c13518809.initial_effect(c)
	-- 将「世界不灭」的卡片密码（32828635）加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,32828635)
	c:EnableReviveLimit()
	-- ①：这张卡的卡名只要在手卡·场上存在当作「破灭之女神 露茵」使用。
	aux.EnableChangeCode(c,46427957,LOCATION_MZONE+LOCATION_HAND)
	-- ②：只要仪式召唤的这张卡在怪兽区域存在，自己场上的仪式怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c13518809.indcon)
	e2:SetTarget(c13518809.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：只使用仪式怪兽作仪式召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(c13518809.condition)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ④：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果④的发动条件：此卡因战斗破坏对方怪兽
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(c13518809.damtg)
	e4:SetOperation(c13518809.damop)
	c:RegisterEffect(e4)
	-- ③：只使用仪式怪兽作仪式召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c13518809.matcon)
	e5:SetOperation(c13518809.matop)
	c:RegisterEffect(e5)
	-- ③：只使用仪式怪兽作仪式召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(c13518809.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
-- 定义效果②的Condition：检查这张卡是否为仪式召唤
function c13518809.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 定义效果②的Target：确认自己场上的受保护对象为仪式怪兽
function c13518809.indtg(e,c)
	return c:IsType(TYPE_RITUAL)
end
-- 过滤条件：非仪式怪兽（用于检测素材中是否存在非仪式怪兽）
function c13518809.mfilter(c)
	return not c:IsType(TYPE_RITUAL)
end
-- 定义效果③的Condition：检查此卡是否满足“仅使用仪式怪兽作为素材进行仪式召唤”的标记
function c13518809.condition(e)
	return e:GetHandler():GetFlagEffect(13518809)>0
end
-- 定义效果④的Target：获取被破坏怪兽的原本攻击力，并设置伤害的操作信息和目标玩家
function c13518809.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 设置效果伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果伤害的参数为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(atk)
	-- 设置操作信息：给与对方以被破坏怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 定义效果④的Operation：给与对方被破坏怪兽原本攻击力数值的伤害
function c13518809.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家以及设定的伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 定义辅助效果的Condition：检查此卡是仪式召唤成功，且素材检查结果为仅使用仪式怪兽（Label为1）
function c13518809.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 定义辅助效果的Operation：给这张卡注册仅使用仪式怪兽作为素材仪式召唤的标记
function c13518809.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(13518809,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 定义素材检查：判断用于仪式召唤的素材是否全部为仪式怪兽，并将结果记录在LabelObject中
function c13518809.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c13518809.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
