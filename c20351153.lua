--幻角獣フュプノコーン
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合这张卡召唤成功时，可以选择场上盖放的1张魔法·陷阱卡破坏。
function c20351153.initial_effect(c)
	-- 创建一个诱发选发效果，对方场上有怪兽存在，自己场上没有怪兽存在的场合这张卡召唤成功时，可以选择场上盖放的1张魔法·陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20351153,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c20351153.descon)
	e3:SetTarget(c20351153.destg)
	e3:SetOperation(c20351153.desop)
	c:RegisterEffect(e3)
end
-- 效果发动条件判断函数，判断是否满足效果发动条件
function c20351153.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件：自己场上怪兽数量小于等于1且对方场上怪兽数量大于0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤函数，用于筛选满足条件的卡片（里侧表示）
function c20351153.filter(c)
	return c:IsFacedown()
end
-- 效果目标选择函数，用于选择场上盖放的魔法·陷阱卡作为破坏对象
function c20351153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c20351153.filter(chkc) end
	-- 检查是否有满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c20351153.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上盖放的1张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c20351153.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置效果操作信息，指定破坏的卡片数量和类型
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行破坏操作
function c20351153.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
