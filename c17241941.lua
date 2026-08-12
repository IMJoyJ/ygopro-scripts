--ダイカミナリ・ジャイクロプス
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽的表示形式变更。
-- 【怪兽效果】
-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。这个卡名的②③的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合才能发动。这张卡的表示形式变更。
-- ②：这张卡的表示形式变更的场合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ③：这张卡在灵摆区域被破坏的场合才能发动。选自己的灵摆区域1张卡回到持有者手卡。
function c17241941.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，允许灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。这个卡名的②③的怪兽效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetCondition(c17241941.rmcon)
	c:RegisterEffect(e1)
	-- 1回合1次，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17241941,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetTarget(c17241941.postg)
	e2:SetOperation(c17241941.posop)
	c:RegisterEffect(e2)
	-- 这张卡召唤成功的场合才能发动。这张卡的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17241941,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c17241941.postg2)
	e3:SetOperation(c17241941.posop2)
	c:RegisterEffect(e3)
	-- 这张卡的表示形式变更的场合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17241941,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,17241941)
	e4:SetTarget(c17241941.destg)
	e4:SetOperation(c17241941.desop)
	c:RegisterEffect(e4)
	-- 这张卡在灵摆区域被破坏的场合才能发动。选自己的灵摆区域1张卡回到持有者手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17241941,3))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,17241942)
	e5:SetCondition(c17241941.thcon)
	e5:SetTarget(c17241941.thtg)
	e5:SetOperation(c17241941.thop)
	c:RegisterEffect(e5)
end
-- 判断此卡是否从额外卡组特殊召唤且通过同调召唤使用
function c17241941.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA)
		and bit.band(c:GetReason(),REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
-- 过滤函数，用于筛选场上可以改变表示形式的灵摆怪兽
function c17241941.posfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanChangePosition()
end
-- 判断是否满足选择目标的条件，即自己场上存在灵摆怪兽，对方场上存在可改变表示形式的怪兽
function c17241941.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingTarget(c17241941.posfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在可改变表示形式的怪兽
		and Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的自己场上的灵摆怪兽作为目标
	local g1=Duel.SelectTarget(tp,c17241941.posfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的对方场上的怪兽作为目标
	local g2=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，表示将要改变2只怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
-- 处理效果，将目标怪兽的表示形式进行变更
function c17241941.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 实际执行改变目标怪兽表示形式的操作
		Duel.ChangePosition(tg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 判断是否满足选择目标的条件，即此卡是否可以改变表示形式
function c17241941.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanChangePosition() end
	-- 设置操作信息，表示将要改变此卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 处理效果，将此卡的表示形式进行变更
function c17241941.posop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行改变此卡表示形式的操作
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 过滤函数，用于筛选场上表侧表示的魔法或陷阱卡
function c17241941.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断是否满足选择目标的条件，即场面上存在满足条件的魔法或陷阱卡
function c17241941.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c17241941.desfilter(chkc) end
	-- 判断场面上是否存在满足条件的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c17241941.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c17241941.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果，将目标卡破坏
function c17241941.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的第一个目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 实际执行破坏目标卡的操作
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否在灵摆区域被破坏且处于表侧表示状态
function c17241941.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsFaceup()
end
-- 判断是否满足选择目标的条件，即自己灵摆区域存在可返回手牌的卡
function c17241941.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己灵摆区域是否存在可返回手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) end
	-- 设置操作信息，表示将要将1张卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_PZONE)
end
-- 处理效果，选择并返回1张灵摆区域的卡到手牌
function c17241941.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的灵摆区域的卡作为目标
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 实际执行将目标卡送入手牌的操作
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
