--サイコ・イレイザー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选从额外卡组特殊召唤的对方场上1只怪兽送去墓地。那之后，对方基本分回复送去墓地的怪兽的原本攻击力和原本守备力之内较高方的数值。
function c9322133.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：选从额外卡组特殊召唤的对方场上1只怪兽送去墓地。那之后，对方基本分回复送去墓地的怪兽的原本攻击力和原本守备力之内较高方的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,9322133+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c9322133.target)
	e1:SetOperation(c9322133.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选从额外卡组特殊召唤且可以送去墓地的卡
function c9322133.filter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA and c:IsAbleToGrave()
end
-- 效果发动的目标检查与操作信息设置
function c9322133.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9322133.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置送去墓地的操作信息，预计将对方场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
	-- 设置回复生命值的操作信息，预计对方玩家回复生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 效果处理的执行函数：将选定的怪兽送去墓地，并让对方回复对应数值的生命值
function c9322133.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在屏幕上提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让发动效果的玩家选择对方场上1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c9322133.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 为选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽送去墓地，并确认其成功送去墓地且在墓地中是怪兽卡
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER) then
			local atk=tc:GetBaseAttack()
			local def=tc:GetBaseDefense()
			local rec=atk>=def and atk or def
			if rec>0 then
				-- 中断当前效果，使后续的回复生命值处理与送去墓地不视为同时处理
				Duel.BreakEffect()
				-- 让对方玩家回复送去墓地怪兽的原本攻击力和原本守备力中较高方的数值
				Duel.Recover(1-tp,rec,REASON_EFFECT)
			end
		end
	end
end
