--スクラム・フォース
-- 效果：
-- ①：自己场上有表侧守备表示怪兽2只以上存在的场合，自己场上的守备表示怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：这张卡被效果破坏的场合，可以作为代替把其他的自己的魔法与陷阱区域1张卡破坏。
function c20920083.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有表侧守备表示怪兽2只以上存在的场合，自己场上的守备表示怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c20920083.con)
	e2:SetTarget(c20920083.tg)
	-- 设置效果值为aux.indoval函数，用于过滤不会被对方效果破坏的怪兽
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ①：自己场上有表侧守备表示怪兽2只以上存在的场合，自己场上的守备表示怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c20920083.con)
	e3:SetTarget(c20920083.tg)
	-- 设置效果值为aux.tgoval函数，用于过滤不会成为对方效果对象的怪兽
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：这张卡被效果破坏的场合，可以作为代替把其他的自己的魔法与陷阱区域1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c20920083.desreptg)
	e4:SetOperation(c20920083.desrepop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为表侧守备表示的怪兽
function c20920083.cfilter(c)
	return c:IsFaceup() and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 条件函数，用于判断自己场上是否存在至少2只表侧守备表示的怪兽
function c20920083.con(e)
	-- 检查以自己为玩家，在自己场上是否存在至少2只满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c20920083.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
-- 目标函数，用于判断目标怪兽是否为守备表示
function c20920083.tg(e,c)
	return c:IsDefensePos()
end
-- 代替破坏的过滤函数，用于判断魔法与陷阱区域的卡是否可以被破坏
function c20920083.repfilter(c,e)
	return c:GetSequence()<5 and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏的触发函数，用于判断是否满足代替破坏的条件
function c20920083.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 检查自己魔法与陷阱区域是否存在至少1张可被破坏的卡
		and Duel.IsExistingMatchingCard(c20920083.repfilter,tp,LOCATION_SZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的1张魔法与陷阱区域的卡作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c20920083.repfilter,tp,LOCATION_SZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		-- 显示选中的卡被选为对象的动画效果
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏的效果执行函数，用于执行实际的破坏操作
function c20920083.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏的原因将选中的卡破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
