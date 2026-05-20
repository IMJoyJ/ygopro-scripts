--ダイナレスラー・ギガ・スピノサバット
-- 效果：
-- 恐龙族调整＋调整以外的怪兽1只以上
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ④：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1张卡破坏。
function c58672736.initial_effect(c)
	-- 添加同调召唤手续：恐龙族调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c58672736.actlimit)
	e1:SetCondition(c58672736.actcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c58672736.atklimit)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58672736,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c58672736.destg)
	e3:SetOperation(c58672736.desop)
	c:RegisterEffect(e3)
	-- ④：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c58672736.reptg)
	e4:SetOperation(c58672736.repop)
	c:RegisterEffect(e4)
end
-- 限制发动效果的卡片类型过滤函数（限制魔法·陷阱卡的发动）
function c58672736.actlimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 限制发动效果的条件函数（这张卡进行战斗的场合）
function c58672736.actcon(e)
	-- 检查当前进行战斗的怪兽是否为这张卡自身
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 攻击限制过滤函数（对方不能选择其他怪兽作为攻击对象）
function c58672736.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 破坏效果的发动条件判定与目标选择函数
function c58672736.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数
function c58672736.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤自己场上可以代替破坏的卡片
function c58672736.repfilter(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的条件判定与代替卡片选择函数
function c58672736.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在除自身以外可以代替破坏的卡片
		and Duel.IsExistingMatchingCard(c58672736.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择用于代替破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择自己场上1张卡片作为代替破坏的卡
		local g=Duel.SelectMatchingCard(tp,c58672736.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
		-- 将选中的代替卡片设置为当前效果的处理对象
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的执行函数
function c58672736.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为代替破坏的目标卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替卡片以代替自身的破坏
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
