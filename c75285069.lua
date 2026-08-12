--モイスチャー星人
-- 效果：
-- 用3只怪兽做这张卡的召唤祭品召唤的场合，对方场上的全部魔法·陷阱破坏。
function c75285069.initial_effect(c)
	-- 用3只怪兽做这张卡的召唤祭品召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75285069,0))  --"解放3只怪兽召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c75285069.ttcon)
	e1:SetOperation(c75285069.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 用3只怪兽做这张卡的召唤祭品召唤的场合，对方场上的全部魔法·陷阱破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75285069,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c75285069.descon)
	e2:SetTarget(c75285069.destg)
	e2:SetOperation(c75285069.desop)
	c:RegisterEffect(e2)
end
-- 解放3只怪兽召唤的条件判定函数
function c75285069.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否可以使用3只怪兽作为祭品进行召唤
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 解放3只怪兽召唤的操作处理函数
function c75285069.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 给玩家发送选择解放怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择3只用于召唤的解放怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选中的怪兽作为召唤素材
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 效果发动条件判定（必须是用3只怪兽做祭品上级召唤成功）
function c75285069.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF
end
-- 过滤魔法和陷阱卡的条件函数
function c75285069.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动目标判定（确认对方场上是否存在魔法·陷阱卡并设置破坏操作信息）
function c75285069.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c75285069.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏对方场上所有魔法·陷阱卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果运行处理（破坏对方场上所有的魔法·陷阱卡）
function c75285069.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c75285069.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的所有魔法·陷阱卡
	Duel.Destroy(g,REASON_EFFECT)
end
