--フェアーウェルカム・ラビュリンス
-- 效果：
-- ①：自己场上有恶魔族怪兽存在的场合，自己或者对方的怪兽的攻击宣言时，以场上1张卡为对象才能发动。那次攻击无效，作为对象的卡破坏。那之后，可以从手卡·卡组选「拉比林斯迷宫」卡以外的1张通常陷阱卡在自己场上盖放。
function c32785578.initial_effect(c)
	-- 效果原文内容：①：自己场上有恶魔族怪兽存在的场合，自己或者对方的怪兽的攻击宣言时，以场上1张卡为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c32785578.condition)
	e1:SetTarget(c32785578.target)
	e1:SetOperation(c32785578.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在恶魔族怪兽
function c32785578.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 效果作用：判断是否满足发动条件（场上有恶魔族怪兽）
function c32785578.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(c32785578.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置效果目标选择逻辑
function c32785578.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 效果作用：检查是否能选择场上一张卡作为目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：过滤手卡和卡组中非拉比林斯迷宫的通常陷阱卡
function c32785578.stfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsSetCard(0x17e) and c:IsSSetable()
end
-- 效果作用：处理效果发动后的操作
function c32785578.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	local res=0
	-- 效果作用：无效攻击并判断目标卡是否有效
	if Duel.NegateAttack() and tc:IsRelateToEffect(e) then
		-- 效果作用：破坏目标卡
		res=Duel.Destroy(tc,REASON_EFFECT)
		-- 效果作用：检索满足条件的通常陷阱卡
		local g=Duel.GetMatchingGroup(c32785578.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 效果作用：询问玩家是否发动追加盖放效果
		if res>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(32785578,0)) then  --"是否选卡盖放？"
			-- 效果作用：中断当前连锁处理
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 效果作用：将选中的卡在自己场上盖放
			Duel.SSet(tp,sg)
		end
	end
	-- 效果作用：调用辅助函数处理追加破坏结算
	aux.LabrynthDestroyOp(e,tp,res)
end
