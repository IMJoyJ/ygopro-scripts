--エキセントリック・デーモン
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以场上1张其他的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：把这张卡解放，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c57624336.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以场上1张其他的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,57624336)
	e2:SetTarget(c57624336.destg1)
	e2:SetOperation(c57624336.desop1)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：把这张卡解放，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,57624337)
	e3:SetCost(c57624336.descost2)
	e3:SetTarget(c57624336.destg2)
	e3:SetOperation(c57624336.desop2)
	c:RegisterEffect(e3)
end
-- 过滤场上魔法·陷阱卡的条件函数
function c57624336.filter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 灵摆效果①的发动条件判定与对象选择
function c57624336.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c57624336.filter1(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 判定场上是否存在除这张卡以外的魔法·陷阱卡作为可选对象
		and Duel.IsExistingTarget(c57624336.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给发动效果的玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张除这张卡以外的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c57624336.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 设置连锁信息，表明该效果的处理为破坏包含所选对象和这张卡在内的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 灵摆效果①的效果处理（破坏所选卡和这张卡）
function c57624336.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一个对象（即要破坏的魔法·陷阱卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡和这张卡一起因效果破坏
		Duel.Destroy(Group.FromCards(tc,e:GetHandler()),REASON_EFFECT)
	end
end
-- 怪兽效果①的发动代价判定与执行（解放自身）
function c57624336.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 怪兽效果①的发动条件判定与对象选择
function c57624336.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 判定场上是否存在除这张卡以外的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 给发动效果的玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明该效果的处理为破坏所选的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 怪兽效果①的效果处理（破坏所选怪兽）
function c57624336.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一个对象（即要破坏的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将作为对象的怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
