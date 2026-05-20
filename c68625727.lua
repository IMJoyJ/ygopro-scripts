--占術姫ペタルエルフ
-- 效果：
-- ①：这张卡反转的场合才能发动。对方场上的表侧攻击表示怪兽全部变成守备表示。这个效果变成守备表示的怪兽不能把表示形式变更。
function c68625727.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。对方场上的表侧攻击表示怪兽全部变成守备表示。这个效果变成守备表示的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c68625727.postg)
	e1:SetOperation(c68625727.posop)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧攻击表示且可以变更表示形式的怪兽
function c68625727.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果①的发动准备（检查是否存在符合条件的怪兽并设置操作信息）
function c68625727.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧攻击表示且可以变更表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68625727.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧攻击表示且可以变更表示形式的怪兽
	local g=Duel.GetMatchingGroup(c68625727.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果①的处理（将符合条件的怪兽变成守备表示，并施加不能变更表示形式的效果）
function c68625727.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有表侧攻击表示且可以变更表示形式的怪兽
	local g=Duel.GetMatchingGroup(c68625727.filter,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变成表侧守备表示，并判断是否有怪兽成功改变了表示形式
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=0 then
		-- 获取本次操作中实际改变了表示形式的怪兽组
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		while oc do
			-- 这个效果变成守备表示的怪兽不能把表示形式变更。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			oc:RegisterEffect(e1)
			oc=og:GetNext()
		end
	end
end
