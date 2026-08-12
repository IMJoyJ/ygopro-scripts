--ディサイシブの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除10星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「影灵衣」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升1000。
-- ②：以对方场上1张里侧表示卡为对象才能发动。那张卡破坏并除外。
function c88240999.initial_effect(c)
	c:EnableReviveLimit()
	-- 「影灵衣」仪式魔法卡降临。这张卡若非以只使用除10星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仪式召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「影灵衣」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88240999,0))  --"攻守上升"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,88240999)
	-- 设置效果发动条件为不在伤害计算后
	e2:SetCondition(aux.dscon)
	e2:SetCost(c88240999.adcost)
	e2:SetTarget(c88240999.adtg)
	e2:SetOperation(c88240999.adop)
	c:RegisterEffect(e2)
	-- ②：以对方场上1张里侧表示卡为对象才能发动。那张卡破坏并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88240999,1))  --"破坏并除外"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,88241000)
	e3:SetTarget(c88240999.destg)
	e3:SetOperation(c88240999.desop)
	c:RegisterEffect(e3)
end
-- 过滤条件：非10星怪兽（用于仪式召唤素材限制）
function c88240999.mat_filter(c)
	return not c:IsLevel(10)
end
-- 效果①的发动代价：将手卡的此卡丢弃
function c88240999.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡作为代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己场上表侧表示的「影灵衣」怪兽
function c88240999.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb4)
end
-- 效果①的发动目标：选择自己场上1只表侧表示的「影灵衣」怪兽
function c88240999.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88240999.filter(chkc) end
	-- 检查自己场上是否存在满足条件的「影灵衣」怪兽
	if chk==0 then return Duel.IsExistingTarget(c88240999.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择并确认自己场上1只表侧表示的「影灵衣」怪兽作为效果对象
	Duel.SelectTarget(tp,c88240999.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：使目标怪兽的攻击力·守备力直到回合结束时上升1000
function c88240999.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：对方场上里侧表示且可以被除外的卡
function c88240999.desfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果②的发动目标：选择对方场上1张里侧表示的卡
function c88240999.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c88240999.desfilter(chkc) end
	-- 检查对方场上是否存在可以被除外的里侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c88240999.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张里侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c88240999.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：除外目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的效果处理：将目标卡片破坏并除外
function c88240999.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏并送去除外区
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
