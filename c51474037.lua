--ヤモイモリ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以把墓地的这张卡除外，以自己场上1只爬虫类族怪兽和对方场上1只表侧表示怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽变成里侧守备表示。
-- ●作为对象的自己怪兽破坏，作为对象的对方怪兽的攻击力直到回合结束时变成0。
function c51474037.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：可以把墓地的这张卡除外，以自己场上1只爬虫类族怪兽和对方场上1只表侧表示怪兽为对象，从以下效果选择1个发动。●作为对象的怪兽变成里侧守备表示。●作为对象的自己怪兽破坏，作为对象的对方怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,51474037)
	-- 将这张卡除外作为cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c51474037.target)
	e1:SetOperation(c51474037.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己场上满足条件的爬虫类族表侧表示怪兽，且对方场上存在可成为效果对象的怪兽
function c51474037.filter1(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
		-- 确保对方场上存在可成为效果对象的怪兽
		and Duel.IsExistingTarget(c51474037.filter2,tp,0,LOCATION_MZONE,1,nil,c:IsCanTurnSet())
end
-- 筛选对方场上满足条件的表侧表示怪兽，可以是能变为里侧守备表示或攻击力大于0的怪兽
function c51474037.filter2(c,check)
	return c:IsFaceup() and (check and c:IsCanTurnSet() or c:GetAttack()>0)
end
-- 设置效果目标并选择发动效果
function c51474037.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件，即自己场上存在符合条件的爬虫类族表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c51474037.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的1只爬虫类族表侧表示怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c51474037.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	local check=tc1:IsCanTurnSet()
	e:SetLabelObject(tc1)
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c51474037.filter2,tp,0,LOCATION_MZONE,1,1,nil,check)
	local sel
	local tc2=g2:GetFirst()
	if tc2:IsAttack(0) then
		-- 选择效果1：使对象怪兽变为里侧守备表示
		sel=Duel.SelectOption(tp,aux.Stringid(51474037,0))  --"变成里侧守备表示"
	elseif not (check and tc2:IsCanTurnSet()) then
		-- 选择效果2：使对象怪兽攻击力变为0
		sel=Duel.SelectOption(tp,aux.Stringid(51474037,1))+1  --"攻击力变成0"
	else
		-- 同时提供两个效果选项供玩家选择
		sel=Duel.SelectOption(tp,aux.Stringid(51474037,0),aux.Stringid(51474037,1))  --"变成里侧守备表示/攻击力变成0"
	end
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
		g1:Merge(g2)
		-- 设置连锁操作信息为改变表示形式和盖放怪兽
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置连锁操作信息为破坏怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	end
end
-- 处理效果的发动
function c51474037.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sel=e:GetLabel()
	if sel==0 then
		local tg=g:Filter(Card.IsRelateToEffect,nil,e)
		-- 将对象怪兽变为里侧守备表示
		Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
	else
		local tc1=e:GetLabelObject()
		local tc2=g:GetFirst()
		if tc2==tc1 then tc2=g:GetNext() end
		-- 判断对象怪兽是否有效并进行破坏，然后使对方怪兽攻击力变为0
		if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2 and tc2:IsRelateToEffect(e) then
			-- 使对象怪兽的攻击力直到回合结束时变成0
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
		end
	end
end
