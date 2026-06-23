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
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤并具有灵摆卡的发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是从额外卡组中不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SSET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c19619755.pencon)
	e1:SetTarget(c19619755.pentg)
	e1:SetOperation(c19619755.penop)
	c:RegisterEffect(e1)
	-- ②：双方受自身的魔法与陷阱区域盖放的卡数量对应的以下所适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19619755.splimit)
	c:RegisterEffect(e2)
	-- ●0张：自己场上的怪兽不能攻击并不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c19619755.atktg)
	c:RegisterEffect(e3)
	-- ●4张以上：自己场上的怪兽的攻击力变成原本数值的2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(c19619755.limval)
	c:RegisterEffect(e4)
	-- 【怪兽效果】①：这张卡在墓地存在，自己场上有魔法·陷阱卡被盖放的场合才能发动。墓地的这张卡在自己的灵摆区域放置。
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
-- 判断是否有自己放置的卡进入魔法与陷阱区域
function c19619755.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
-- 设置灵摆区域放置效果的处理信息，包括将卡从墓地移至灵摆区
function c19619755.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有可用的灵摆区域位置
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	-- 设置操作信息，表示将要从墓地移至灵摆区的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行将墓地中的卡移至灵摆区域的操作
function c19619755.penop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将卡移动到指定玩家的灵摆区域并正面表示
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 限制非额外卡组的灵摆召唤
function c19619755.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsLocation(LOCATION_EXTRA)
end
-- 用于统计魔法与陷阱区域盖放的卡的过滤函数
function c19619755.countfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 判断是否满足不能攻击的条件
function c19619755.atktg(e,c)
	local tp=c:GetControler()
	-- 当魔法与陷阱区域没有盖放的卡时，使怪兽不能攻击
	return Duel.GetMatchingGroupCount(c19619755.countfilter,tp,LOCATION_SZONE,0,nil)==0
end
-- 限制魔法与陷阱区域没有盖放的卡时不能发动效果
function c19619755.limval(e,re,rp)
	local rc=re:GetHandler()
	local tp=rc:GetControler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		-- 当魔法与陷阱区域没有盖放的卡时，禁止发动效果
		and Duel.GetMatchingGroupCount(c19619755.countfilter,tp,LOCATION_SZONE,0,nil)==0
end
-- 判断魔法与陷阱区域盖放的卡数量是否大于等于4
function c19619755.atkcon0(e)
	-- 统计魔法与陷阱区域盖放的卡数量是否大于等于4
	return Duel.GetMatchingGroupCount(c19619755.countfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)>=4
end
-- 判断魔法与陷阱区域盖放的卡数量是否大于等于4
function c19619755.atkcon1(e)
	-- 统计魔法与陷阱区域盖放的卡数量是否大于等于4
	return Duel.GetMatchingGroupCount(c19619755.countfilter,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil)>=4
end
-- 设置怪兽攻击力变为原本数值的2倍
function c19619755.atkval(e,c)
	return c:GetBaseAttack()*2
end
