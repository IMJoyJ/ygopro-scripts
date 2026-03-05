--ロード・オブ・ザ・レッド
-- 效果：
-- 「真红眼转生」降临。
-- ①：1回合1次，自己或者对方把「真红王」以外的魔法·陷阱·怪兽的效果发动时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：1回合1次，自己或者对方把「真红王」以外的魔法·陷阱·怪兽的效果发动时，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c19025379.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：①：1回合1次，自己或者对方把「真红王」以外的魔法·陷阱·怪兽的效果发动时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19025379,0))  --"选择一张怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c19025379.descon)
	e1:SetTarget(c19025379.destg1)
	e1:SetOperation(c19025379.desop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(19025379,1))  --"选择一张魔法·陷阱破坏"
	e2:SetTarget(c19025379.destg2)
	e2:SetOperation(c19025379.desop2)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否满足效果发动条件，即发动效果的卡不是真红王且自身未因战斗破坏
function c19025379.descon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(19025379) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 规则层面作用：设置效果处理时的目标选择逻辑，确保选择的是场上怪兽
function c19025379.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 规则层面作用：检查是否有满足条件的怪兽可作为目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：向对方玩家提示本效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上一只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面作用：设置效果操作信息，表明将要破坏一张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：定义用于筛选魔法·陷阱卡的过滤器函数
function c19025379.desfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面作用：设置第二个效果处理时的目标选择逻辑，确保选择的是场上魔法·陷阱卡
function c19025379.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c19025379.desfilter2(chkc) end
	-- 规则层面作用：检查是否有满足条件的魔法·陷阱卡可作为目标
	if chk==0 then return Duel.IsExistingTarget(c19025379.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 规则层面作用：向对方玩家提示本效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择场上一张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c19025379.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面作用：设置效果操作信息，表明将要破坏一张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：执行第一个效果的处理，破坏选定的怪兽
function c19025379.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 规则层面作用：将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 规则层面作用：执行第二个效果的处理，破坏选定的魔法·陷阱卡
function c19025379.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标魔法·陷阱卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
