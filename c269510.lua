--天火の牢獄
-- 效果：
-- ①：场上的龙族怪兽的守备力上升300。
-- ②：双方不能把连接标记数量比场上的连接怪兽少的连接怪兽连接召唤，连接怪兽以外的怪兽不能攻击。
-- ③：场上有电子界族连接怪兽2只以上存在的场合，以下效果适用。
-- ●电子界族怪兽发动的效果无效化。
-- ●场上的电子界族怪兽不能攻击，不会成为攻击对象，也不会成为效果的对象。
function c269510.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的龙族怪兽的守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 检索满足条件的龙族怪兽组
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ②：双方不能把连接标记数量比场上的连接怪兽少的连接怪兽连接召唤，连接怪兽以外的怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c269510.splimit)
	c:RegisterEffect(e3)
	-- ②：双方不能把连接标记数量比场上的连接怪兽少的连接怪兽连接召唤，连接怪兽以外的怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c269510.atktg)
	c:RegisterEffect(e4)
	-- ③：场上有电子界族连接怪兽2只以上存在的场合，以下效果适用。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(c269510.discon)
	e5:SetOperation(c269510.disop)
	c:RegisterEffect(e5)
	-- ③：场上有电子界族连接怪兽2只以上存在的场合，以下效果适用。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetCondition(c269510.limcon)
	e6:SetTarget(c269510.atlimit)
	c:RegisterEffect(e6)
	-- ③：场上有电子界族连接怪兽2只以上存在的场合，以下效果适用。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetCondition(c269510.limcon)
	e7:SetValue(c269510.atlimit)
	c:RegisterEffect(e7)
	-- ③：场上有电子界族连接怪兽2只以上存在的场合，以下效果适用。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetCondition(c269510.limcon)
	-- 检索满足条件的电子界族怪兽组
	e8:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERSE))
	e8:SetValue(1)
	c:RegisterEffect(e8)
end
-- 过滤出场上正面表示的连接怪兽
function c269510.limfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 判断是否为连接召唤且连接标记数量少于场上的连接怪兽
function c269510.splimit(e,c,tp,sumtp,sumpos)
	-- 获取场上正面表示的连接怪兽组
	local g=Duel.GetMatchingGroup(c269510.limfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()<=0 then return false end
	local mg,lk=g:GetMinGroup(Card.GetLink)
	return lk>c:GetLink() and bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 过滤出非连接怪兽
function c269510.atktg(e,c)
	return not c:IsType(TYPE_LINK)
end
-- 过滤出场上正面表示的电子界族连接怪兽
function c269510.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- 判断连锁发动的怪兽是否为电子界族且场上有2只以上电子界族连接怪兽
function c269510.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁发动的怪兽种族
	local race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)
	-- 判断场上正面表示的电子界族连接怪兽数量是否大于1
	return Duel.GetMatchingGroupCount(c269510.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>1
		and re:IsActiveType(TYPE_MONSTER) and race&RACE_CYBERSE>0
end
-- 使连锁效果无效
function c269510.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
-- 判断场上正面表示的电子界族连接怪兽数量是否大于1
function c269510.limcon(e)
	-- 判断场上正面表示的电子界族连接怪兽数量是否大于1
	return Duel.GetMatchingGroupCount(c269510.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)>1
end
-- 判断目标怪兽是否为正面表示的电子界族怪兽
function c269510.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
