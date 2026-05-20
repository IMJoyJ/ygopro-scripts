--邪龍アナンタ
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把爬虫类族怪兽全部除外的场合才能特殊召唤。
-- ①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×600。
-- ②：自己结束阶段，以场上1张卡为对象发动。这张卡在自己场上表侧表示存在的场合，作为对象的卡破坏。
function c8400623.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡不能通过通常召唤以外的常规特殊召唤方式召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 从自己墓地以及自己场上的表侧表示怪兽之中把爬虫类族怪兽全部除外的场合才能特殊召唤。①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c8400623.spcon)
	e2:SetOperation(c8400623.spop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段，以场上1张卡为对象发动。这张卡在自己场上表侧表示存在的场合，作为对象的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8400623,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c8400623.descon)
	e3:SetTarget(c8400623.destg)
	e3:SetOperation(c8400623.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己墓地以及自己场上表侧表示的爬虫类族怪兽
function c8400623.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 特殊召唤规则的条件判定函数
function c8400623.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上和墓地中所有符合条件的爬虫类族怪兽
	local g=Duel.GetMatchingGroup(c8400623.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 判定是否存在可除外的怪兽，且除外这些怪兽后有可用的怪兽区域
	return #g>0 and Duel.GetMZoneCount(tp,g)>0
end
-- 特殊召唤规则的具体执行函数，处理除外怪兽并设置攻防数值
function c8400623.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取自己场上和墓地中所有符合条件的爬虫类族怪兽
	local g=Duel.GetMatchingGroup(c8400623.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 将符合条件的爬虫类族怪兽全部除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	-- ①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(g:GetCount()*600)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- 破坏效果的发动条件判定函数
function c8400623.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 破坏效果的发动准备与目标选择函数
function c8400623.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 向玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表明该效果的操作为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的具体执行函数
function c8400623.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	-- 获取效果发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
