--トーテムポール
-- 效果：
-- ①：对方不能把自己场上的原本攻击力是0的岩石族怪兽作为效果的对象。
-- ②：对方怪兽的攻击宣言时才能发动1次。那次攻击无效，给这张卡放置1个指示物。
-- ③：这张卡有3个指示物放置的场合，这张卡送去墓地。
-- ④：自己墓地有攻击力0的岩石族怪兽3种类以上存在的场合，把墓地的这张卡除外才能发动。这个回合，对方受到的效果伤害变成2倍。
local s,id,o=GetID()
-- 初始化函数：开启自我送墓全局标记，允许放置指示物，并依次注册①～④效果：通用发动空效果、①对象免疫、②无效攻击并加指示物、③指示物满3时自动送墓、④墓地除外发动伤害加倍。
function s.initial_effect(c)
	-- 开启全局标记GLOBALFLAG_SELF_TOGRAVE，使③的“自我送墓”可以不入连锁地作为永续效果处理。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	c:EnableCounterPermit(0x68)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方不能把自己场上的原本攻击力是0的岩石族怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.intg)
	-- 设置该保护效果的判定值为aux.tgoval，使对方的卡的效果不能以被保护怪兽为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时才能发动1次。那次攻击无效，给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.ncon)
	e3:SetTarget(s.ntg)
	e3:SetOperation(s.nop)
	c:RegisterEffect(e3)
	-- ③：这张卡有3个指示物放置的场合，这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_TOGRAVE)
	e4:SetCondition(s.sdcon)
	c:RegisterEffect(e4)
	-- ④：自己墓地有攻击力0的岩石族怪兽3种类以上存在的场合，把墓地的这张卡除外才能发动。这个回合，对方受到的效果伤害变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	-- 设置发动代价为把墓地的这张卡除外（aux.bfgcost），作为④发动必须支付的cost。
	e5:SetCost(aux.bfgcost)
	e5:SetCondition(s.ddcon)
	e5:SetOperation(s.ddop)
	c:RegisterEffect(e5)
end
-- 定义①的过滤函数：符合“原本攻击力为0的岩石族怪兽”且表侧表示时才受到该保护效果影响。
function s.intg(e,c)
	return c:IsFaceup() and c:GetBaseAttack()==0 and c:IsRace(RACE_ROCK)
end
-- 定义②的发动条件：当前回合玩家不是这张卡的控制者（即对方回合），满足“对方怪兽的攻击宣言时”的时点条件。
function s.ncon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不等于本卡控制者，用于确认是对方回合（对方怪兽攻击宣言）。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义②发动时的合法判定：若本卡可以放置1个指示物则允许发动，并将连锁信息设置为放置1个指示物。
function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x68,1) end
	-- 将连锁的操作信息设为CATEGORY_COUNTER，标明本次效果将放置1个0x68指示物，供其他卡片响应时参考。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x68)
end
-- 定义②的效果处理：先无效那次攻击，然后若这张卡仍与效果关联（未被离场等），给这张卡放置1个0x68指示物。
function s.nop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateAttack无效攻击；如果无效失败（攻击已被其他效果无效或怪兽不能攻击），则不再继续处理后续放置指示物。
	if not Duel.NegateAttack() then return end
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x68,1)
	end
end
-- 定义③的条件：当这张卡上的0x68指示物数量达到3时，触发自我送墓。
function s.sdcon(e)
	return e:GetHandler():GetCounter(0x68)==3
end
-- 定义用于④的墓地过滤函数：攻击力为0且种族为岩石族的怪兽。
function s.ddfilter(c)
	return c:IsAttack(0) and c:IsRace(RACE_ROCK)
end
-- 定义④的发动条件：自己墓地中满足条件的岩石族怪兽种类数达到3种以上。
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有攻击力为0的岩石族怪兽，存入临时集合g。
	local g=Duel.GetMatchingGroup(s.ddfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 定义④的效果处理：在本回合内，为对方玩家施加一个“受到的效果伤害翻倍”的领域效果，直到结束阶段。
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方受到的效果伤害变成2倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的伤害改变效果注册到游戏中，使该效果持续生效至回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义伤害数值修改函数：当伤害由卡的效果造成时，将该伤害值乘以2；其他伤害（如战斗伤害）保持不变。
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT==REASON_EFFECT then
		return val*2
	else return val end
end
