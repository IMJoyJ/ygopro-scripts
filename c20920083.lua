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
	-- ①：自己场上有表侧守备表示怪兽2只以上存在的场合，自己场上的守备表示怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c20920083.con)
	e2:SetTarget(c20920083.tg)
	-- 设置免疫效果破坏的判定值：仅当破坏效果来自对方玩家时，我方守备表示怪兽才不会因此被效果破坏。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ①：自己场上有表侧守备表示怪兽2只以上存在的场合，自己场上的守备表示怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c20920083.con)
	e3:SetTarget(c20920083.tg)
	-- 设置不能成为效果对象的判定值：仅当效果来自对方玩家时，我方守备表示怪兽才不能成为该效果的对象。
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
-- 过滤条件：该怪兽为表侧表示且为表侧守备表示。
function c20920083.cfilter(c)
	return c:IsFaceup() and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果满足条件：自己场上有表侧守备表示怪兽2只以上存在。
function c20920083.con(e)
	-- 检查自己怪兽区是否存在至少2只满足cfilter的表侧守备表示怪兽，作为效果成立的发动条件。
	return Duel.IsExistingMatchingCard(c20920083.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
-- 效果适用对象：只对守备表示怪兽生效。
function c20920083.tg(e,c)
	return c:IsDefensePos()
end
-- 代替破坏对象过滤：自己的魔法与陷阱区域（不含场地魔法格）中可被效果破坏、且未处于破坏确定状态的卡。
function c20920083.repfilter(c,e)
	return c:GetSequence()<5 and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- ②的代替破坏触发判定：这张卡被效果破坏时，确认其不是在代替破坏处理中、在场上表侧表示，且存在其他可作为代替破坏对象的魔陷卡。
function c20920083.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		-- 并且场上存在至少1张满足repfilter的其他魔法与陷阱区域卡可用作代替破坏对象。
		and Duel.IsExistingMatchingCard(c20920083.repfilter,tp,LOCATION_SZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示“请选择要代替破坏的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己的魔法与陷阱区域选择1张满足repfilter的卡作为代替破坏对象。
		local g=Duel.SelectMatchingCard(tp,c20920083.repfilter,tp,LOCATION_SZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		-- 展示被选为代替破坏对象的卡，并将其记录为广义的选中对象。
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏的后续处理：清除被选卡上的破坏确定状态，然后将其破坏以代替本卡的破坏。
function c20920083.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以“效果破坏+代替破坏”的理由将被选的卡破坏，从而代替这张卡被效果破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
