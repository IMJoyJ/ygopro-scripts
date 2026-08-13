--グラビティ・ボール
-- 效果：
-- 反转：对方场上存在的表侧表示怪兽全部的表示形式改变。
function c29216198.initial_effect(c)
	-- 反转：对方场上存在的表侧表示怪兽全部的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29216198,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c29216198.target)
	e1:SetOperation(c29216198.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时进行合法性判定（反转效果在反转时必定满足发动条件），并检索对方场上全部表侧表示怪兽，将这批卡及数量写入操作信息，声明本效果将改变表示形式，供其他卡的效果检测连锁信息使用。
function c29216198.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上全部表侧表示怪兽的集合，作为本次改变表示形式的效果对象。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息：分类为改变表示形式（CATEGORY_POSITION），对象为对方场上表侧表示怪兽全体，数量为其数量，用于告知系统该效果将进行的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 效果处理时，重新获取对方场上当前存在的全部表侧表示怪兽；若存在，则将它们的表示形式全部变更（表侧攻击表示与表侧守备表示互换）。
function c29216198.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取效果处理时对方场上的全部表侧表示怪兽，确保以当前实际存在的表侧怪兽为对象。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将对象怪兽的表示形式全部改变：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示。
		Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
