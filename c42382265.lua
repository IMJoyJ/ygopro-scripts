--DDスケール・サーベイヤー
-- 效果：
-- ←9 【灵摆】 9→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己·对方的准备阶段，以自己·对方的灵摆区域最多2张卡为对象才能发动。那些卡的灵摆刻度直到回合结束时变成0。
-- 【怪兽效果】
-- 这个卡名的①②③的怪兽效果1回合各能使用1次。
-- ①：自己场上有「DD」灵摆怪兽卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。这张卡的等级变成4星。
-- ③：这张卡被送去墓地的场合或者表侧加入额外卡组的场合，以自己场上1张「DD」灵摆怪兽卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册所有效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己·对方的准备阶段，以自己·对方的灵摆区域最多2张卡为对象才能发动。那些卡的灵摆刻度直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"改变刻度"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	-- ①：自己场上有「DD」灵摆怪兽卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。这张卡的等级变成4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"改变等级"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合或者表侧加入额外卡组的场合，以自己场上1张「DD」灵摆怪兽卡为对象才能发动。那张卡回到手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))  --"回到手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id+o*3)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_TO_DECK)
	e6:SetCondition(s.thcon)
	c:RegisterEffect(e6)
end
-- 过滤函数，判断灵摆刻度不为0的灵摆卡
function s.scfilter(c)
	return c:GetLeftScale()~=0
end
-- 设置灵摆效果的目标选择函数
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and s.scfilter(chkc) end
	-- 检查是否有满足条件的灵摆卡作为目标
	if chk==0 then return Duel.IsExistingTarget(s.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择灵摆区域1到2张满足条件的卡作为效果对象
	Duel.SelectTarget(tp,s.scfilter,tp,LOCATION_PZONE,LOCATION_PZONE,1,2,nil)
end
-- 执行灵摆效果，将目标卡的灵摆刻度设为0
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 遍历目标卡组中的每张卡
	for tc in aux.Next(tg) do
		-- 创建改变左刻度的永久效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(0)
		tc:RegisterEffect(e2)
	end
end
-- 过滤函数，判断场上存在的「DD」灵摆怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 判断是否满足特殊召唤的条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「DD」灵摆怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤效果的目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置等级改变效果的目标选择函数
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return not c:IsLevel(4) end
end
-- 执行等级改变效果
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsLevel(4) then
		-- 创建改变等级的永久效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足回到手牌效果的条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
-- 过滤函数，判断可以返回手牌的「DD」灵摆怪兽
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsFaceup() and c:IsSetCard(0xaf)
		and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 设置回到手牌效果的目标选择函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否有满足条件的「DD」灵摆怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张满足条件的「DD」灵摆怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置回到手牌效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行回到手牌效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
