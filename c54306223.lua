--ヴェノム・スワンプ
-- 效果：
-- 每次双方回合的结束阶段，给场上表侧表示存在的名字带有「蛇毒」的怪兽以外的表侧表示存在的全部怪兽放置1个毒指示物。每有1个毒指示物，攻击力下降500。被这个效果把攻击力变成0的怪兽破坏。
function c54306223.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次双方回合的结束阶段，给场上表侧表示存在的名字带有「蛇毒」的怪兽以外的表侧表示存在的全部怪兽放置1个毒指示物
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54306223,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c54306223.acop)
	c:RegisterEffect(e2)
	-- 每有1个毒指示物，攻击力下降500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(c54306223.atkval)
	c:RegisterEffect(e3)
	-- 被这个效果把攻击力变成0的怪兽破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54306223,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+54306223)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c54306223.destg)
	e4:SetOperation(c54306223.desop)
	c:RegisterEffect(e4)
end
c54306223.mentioned_counter={
	[0x1009]=true,
}
-- 攻击力下降数值的计算函数：返回该怪兽上的毒指示物数量乘以-500的数值
function c54306223.atkval(e,c)
	return c:GetCounter(0x1009)*-500
end
-- 结束阶段的处理函数：给场上所有可以放置毒指示物且不是名字带有「蛇毒」的怪兽各放置1个毒指示物，并把因此攻击力变成0的怪兽记录下来，触发破坏这些怪兽的自定义事件
function c54306223.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 获取双方主要怪兽区的全部怪兽
	local tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=tg:GetFirst()
	while tc do
		if tc:IsCanAddCounter(0x1009,1) and not tc:IsSetCard(0x50) then
			local atk=tc:GetAttack()
			tc:AddCounter(0x1009,1)
			if atk>0 and tc:IsAttack(0) then
				g:AddCard(tc)
			end
		end
		tc=tg:GetNext()
	end
	if g:GetCount()>0 then
		-- 为放置指示物后攻击力变成0的怪兽组触发自定义事件，以发动破坏这些怪兽的效果
		Duel.RaiseEvent(g,EVENT_CUSTOM+54306223,e,0,0,0,0)
	end
end
-- 破坏效果的目标函数：把事件中攻击力变成0的怪兽设置为连锁对象，并设置破坏分类的操作信息
function c54306223.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把触发本次事件的攻击力变成0的怪兽设置为当前连锁的对象
	Duel.SetTargetCard(eg)
	-- 设置破坏分类的操作信息，对象为该事件中攻击力变成0的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 破坏效果的处理函数：筛选出仍与效果相关的怪兽并将其以效果原因破坏
function c54306223.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因把攻击力变成0的怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
