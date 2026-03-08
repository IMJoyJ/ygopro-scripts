--スカイスクレイパー・シュート
-- 效果：
-- ①：以自己场上1只「元素英雄」融合怪兽为对象才能发动。比那只怪兽攻击力高的对方场上的表侧表示怪兽全部破坏。那之后，给与对方这个效果破坏送去墓地的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。自己的场地区域有「摩天楼」场地魔法卡存在的场合，给与对方的伤害变成这个效果破坏送去墓地的怪兽全部的原本攻击力的合计数值。
function c40522482.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只「元素英雄」融合怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40522482.target)
	e1:SetOperation(c40522482.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选满足条件的「元素英雄」融合怪兽作为效果对象
function c40522482.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION)
		-- 效果作用：检查是否存在攻击力高于该怪兽的对方怪兽
		and Duel.IsExistingMatchingCard(c40522482.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 效果作用：定义破坏条件，即攻击力高于指定值的对方怪兽
function c40522482.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 效果原文内容：比那只怪兽攻击力高的对方场上的表侧表示怪兽全部破坏。那之后，给与对方这个效果破坏送去墓地的怪兽之内原本攻击力最高的怪兽的那个数值的伤害。
function c40522482.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40522482.filter(chkc,tp) end
	-- 效果作用：判断是否满足发动条件，即是否存在符合条件的「元素英雄」融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c40522482.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 效果作用：提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 效果作用：选择符合条件的「元素英雄」融合怪兽作为效果对象
	local tg=Duel.SelectTarget(tp,c40522482.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local atk=tg:GetFirst():GetAttack()
	-- 效果作用：获取所有攻击力高于该怪兽的对方怪兽
	local g=Duel.GetMatchingGroup(c40522482.desfilter,tp,0,LOCATION_MZONE,nil,atk)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 效果作用：获取玩家场地区域的场地魔法卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local dam=0
	if fc and c40522482.ffilter(fc) then
		dam=g:GetSum(Card.GetBaseAttack)
	else
		g,dam=g:GetMaxGroup(Card.GetBaseAttack)
	end
	-- 效果作用：设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,dam)
end
-- 效果作用：判断是否为「摩天楼」场地魔法卡
function c40522482.ffilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf6)
end
-- 效果原文内容：自己的场地区域有「摩天楼」场地魔法卡存在的场合，给与对方的伤害变成这个效果破坏送去墓地的怪兽全部的原本攻击力的合计数值。
function c40522482.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 效果作用：获取所有攻击力高于该怪兽的对方怪兽
	local g=Duel.GetMatchingGroup(c40522482.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	-- 效果作用：执行破坏操作并判断是否成功
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 效果作用：筛选出被破坏送入墓地的怪兽
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		if og:GetCount()==0 then return end
		-- 效果作用：获取玩家场地区域的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		local dam=0
		if fc and c40522482.ffilter(fc) then
			dam=og:GetSum(Card.GetBaseAttack)
		else
			g,dam=og:GetMaxGroup(Card.GetBaseAttack)
		end
		if dam>0 then
			-- 效果作用：中断当前效果处理，使后续处理错开时点
			Duel.BreakEffect()
			-- 效果作用：对对方造成伤害
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
