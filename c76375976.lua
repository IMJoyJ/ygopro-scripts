--魔鍾洞
-- 效果：
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，对方不能把怪兽的效果发动，也不能攻击宣言。
-- ②：自己场上的怪兽数量比对方场上的怪兽多的场合，自己不能把怪兽的效果发动，也不能攻击宣言。
-- ③：自己·对方的结束阶段，双方场上的怪兽数量相同的场合发动。这张卡破坏。
function c76375976.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，对方不能把怪兽的效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c76375976.actcona)
	e2:SetValue(c76375976.actlimit)
	c:RegisterEffect(e2)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，对方……也不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c76375976.actcona)
	c:RegisterEffect(e3)
	-- ②：自己场上的怪兽数量比对方场上的怪兽多的场合，自己不能把怪兽的效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(c76375976.actconb)
	e4:SetValue(c76375976.actlimit)
	c:RegisterEffect(e4)
	-- ②：自己场上的怪兽数量比对方场上的怪兽多的场合，自己……也不能攻击宣言。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(c76375976.actconb)
	c:RegisterEffect(e5)
	-- ③：自己·对方的结束阶段，双方场上的怪兽数量相同的场合发动。这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(76375976,0))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c76375976.descon)
	e6:SetTarget(c76375976.destg)
	e6:SetOperation(c76375976.desop)
	c:RegisterEffect(e6)
end
-- 判定对方场上的怪兽数量是否比自己场上的怪兽多
function c76375976.actcona(e)
	local tp=e:GetHandler():GetControler()
	-- 返回自己场上的怪兽数量是否小于对方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 判定自己场上的怪兽数量是否比对方场上的怪兽多
function c76375976.actconb(e)
	local tp=e:GetHandler():GetControler()
	-- 返回自己场上的怪兽数量是否大于对方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 过滤出怪兽卡的效果，用于限制发动
function c76375976.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判定双方场上的怪兽数量是否相同
function c76375976.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回双方场上的怪兽数量是否相等
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 破坏效果的发动准备，设置破坏自身的操作信息
function c76375976.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的执行，若这张卡在场则将其破坏
function c76375976.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
