--EM五虹の魔術師
-- 效果：
-- ←12 【灵摆】 12→
-- ①：自己不是从额外卡组中不能灵摆召唤。这个效果不会被无效化。
-- ②：双方受自身的魔法与陷阱区域盖放的卡数量对应的以下所适用。
-- ●0张：自己场上的怪兽不能攻击并不能把效果发动。
-- ●4张以上：自己场上的怪兽的攻击力变成原本数值的2倍。
-- 【怪兽效果】
-- ①：这张卡在墓地存在，自己场上有魔法·陷阱卡被盖放的场合才能发动。墓地的这张卡在自己的灵摆区域放置。
function c19619755.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可作为灵摆卡发动、参与灵摆召唤等基础规则处理。
	aux.EnablePendulumAttribute(c)
	-- 【怪兽效果】①：这张卡在墓地存在，自己场上有魔法·陷阱卡被盖放的场合才能发动。墓地的这张卡在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SSET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c19619755.pencon)
	e1:SetTarget(c19619755.pentg)
	e1:SetOperation(c19619755.penop)
	c:RegisterEffect(e1)
	-- ①：自己不是从额外卡组中不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19619755.splimit)
	c:RegisterEffect(e2)
	-- ●0张：自己场上的怪兽不能攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c19619755.atktg)
	c:RegisterEffect(e3)
	-- 自己场上的怪兽不能把效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(c19619755.limval)
	c:RegisterEffect(e4)
	-- ●4张以上：自己场上的怪兽的攻击力变成原本数值的2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SET_ATTACK)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(c19619755.atkcon0)
	e5:SetValue(c19619755.atkval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCondition(c19619755.atkcon1)
	c:RegisterEffect(e6)
end
-- 判断触发事件中是否存在由tp玩家放置的魔法·陷阱卡，即满足‘自己场上有魔法·陷阱卡被盖放’的发动条件。
function c19619755.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 效果发动的目标判定与操作信息设置：检查自己灵摆区域是否有空位，并记录此卡将离开墓地。
function c19619755.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的自检：自己的灵摆区域（左/右）至少有一个空格可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 设置本次连锁的操作信息，声明墓地的这张卡将被移动（离开墓地），供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：若墓地的这张卡仍与本效果关联，则将其移动到自己的灵摆区域。
function c19619755.penop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧表示移动到自己的灵摆区域，并立刻适用其效果。
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 灵摆召唤限制：若召唤方式为灵摆召唤且怪兽不是从额外卡组而来，则禁止该召唤，实现‘不是从额外卡组中不能灵摆召唤’。
function c19619755.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsLocation(LOCATION_EXTRA)
end
-- 筛选里侧表示且位于魔陷区前5格的卡，用于统计玩家后场盖放的魔法·陷阱卡数量。
function c19619755.countfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 根据怪兽控制者后场盖放数量是否为0，决定该怪兽是否不能攻击（0张时禁止攻击）。
function c19619755.atktg(e,c)
	local tp=c:GetControler()
	-- 统计该玩家魔陷区前5格中里侧盖放卡的数量并判断是否为0。
	return Duel.GetMatchingGroupCount(c19619755.countfilter,tp,LOCATION_SZONE,0,nil)==0
end
-- 禁止效果发动的判断：当某玩家后场盖放数量为0时，其场上怪兽不能把效果发动。
function c19619755.limval(e,re,rp)
	local rc=re:GetHandler()
	local tp=rc:GetControler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		-- 追加判断：该效果发动者后场盖放数量为0。
		and Duel.GetMatchingGroupCount(c19619755.countfilter,tp,LOCATION_SZONE,0,nil)==0
end
-- 攻击力翻倍效果的条件：己方后场盖放卡数量达到4张以上。
function c19619755.atkcon0(e)
	-- 统计己方魔陷区前5格中里侧盖放卡的数量并判断是否不少于4张。
	return Duel.GetMatchingGroupCount(c19619755.countfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)>=4
end
-- 攻击力翻倍效果对对方也适用：对方后场盖放卡数量达到4张以上时，对方场上怪兽攻击力翻倍。
function c19619755.atkcon1(e)
	-- 统计对方魔陷区前5格中里侧盖放卡的数量并判断是否不少于4张。
	return Duel.GetMatchingGroupCount(c19619755.countfilter,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil)>=4
end
-- 将攻击力设定为原本攻击力的2倍。
function c19619755.atkval(e,c)
	return c:GetBaseAttack()*2
end
