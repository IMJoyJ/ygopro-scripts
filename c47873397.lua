--トーテムポール
-- 效果：
-- ①：对方不能把自己场上的原本攻击力是0的岩石族怪兽作为效果的对象。
-- ②：对方怪兽的攻击宣言时才能发动1次。那次攻击无效，给这张卡放置1个指示物。
-- ③：这张卡有3个指示物放置的场合，这张卡送去墓地。
-- ④：自己墓地有攻击力0的岩石族怪兽3种类以上存在的场合，把墓地的这张卡除外才能发动。这个回合，对方受到的效果伤害变成2倍。
local s,id,o=GetID()
-- 初始化效果函数，启用全局标记、设置指示物许可并注册多个效果
function s.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_SELF_TOGRAVE以允许自身送墓不入连锁
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	c:EnableCounterPermit(0x68)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方不能把自己场上的原本攻击力是0的岩石族怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.intg)
	-- 设置过滤函数，用于判断目标是否为己方场上原本攻击力为0的岩石族怪兽
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 对方怪兽的攻击宣言时才能发动1次。那次攻击无效，给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.ncon)
	e3:SetTarget(s.ntg)
	e3:SetOperation(s.nop)
	c:RegisterEffect(e3)
	-- 这张卡有3个指示物放置的场合，这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_TOGRAVE)
	e4:SetCondition(s.sdcon)
	c:RegisterEffect(e4)
	-- 自己墓地有攻击力0的岩石族怪兽3种类以上存在的场合，把墓地的这张卡除外才能发动。这个回合，对方受到的效果伤害变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	-- 设置发动时的费用为将此卡除外
	e5:SetCost(aux.bfgcost)
	e5:SetCondition(s.ddcon)
	e5:SetOperation(s.ddop)
	c:RegisterEffect(e5)
end
-- 判断目标是否为己方场上原本攻击力为0且种族为岩石族的怪兽
function s.intg(e,c)
	return c:IsFaceup() and c:GetBaseAttack()==0 and c:IsRace(RACE_ROCK)
end
-- 判断是否为对方攻击宣言时
function s.ncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是效果使用者
	return Duel.GetTurnPlayer()~=tp
end
-- 设置指示物效果的目标，检查是否可以放置1个指示物
function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x68,1) end
	-- 设置操作信息，表示将要放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x68)
end
-- 执行指示物效果的操作，无效攻击并放置指示物
function s.nop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击，若失败则返回
	if not Duel.NegateAttack() then return end
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x68,1)
	end
end
-- 判断是否已放置3个指示物
function s.sdcon(e)
	return e:GetHandler():GetCounter(0x68)==3
end
-- 过滤函数，用于筛选墓地中的攻击力为0且种族为岩石族的怪兽
function s.ddfilter(c)
	return c:IsAttack(0) and c:IsRace(RACE_ROCK)
end
-- 判断是否满足发动条件：墓地存在3种类以上攻击力为0的岩石族怪兽
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(s.ddfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 设置伤害变化效果，使对方受到的效果伤害翻倍
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册伤害变化效果，使对方受到的效果伤害变为2倍
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害变化效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断伤害来源是否为效果，若是则将伤害翻倍
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT==REASON_EFFECT then
		return val*2
	else return val end
end
