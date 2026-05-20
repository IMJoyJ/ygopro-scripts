--ヴェノム・スワンプ
-- 效果：
-- 每次双方回合的结束阶段，给场上表侧表示存在的名字带有「蛇毒」的怪兽以外的表侧表示存在的全部怪兽放置1个毒指示物。每有1个毒指示物，攻击力下降500。被这个效果把攻击力变成0的怪兽破坏。
function c54306223.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次双方回合的结束阶段，给场上表侧表示存在的名字带有「蛇毒」的怪兽以外的表侧表示存在的全部怪兽放置1个毒指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54306223,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c54306223.acop)
	c:RegisterEffect(e2)
	-- 每有1个毒指示物，攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(c54306223.atkval)
	c:RegisterEffect(e3)
	-- 被这个效果把攻击力变成0的怪兽破坏。
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
-- 计算怪兽因毒指示物而下降的攻击力数值（每个毒指示物下降500点）。
function c54306223.atkval(e,c)
	return c:GetCounter(0x1009)*-500
end
-- 在结束阶段给场上「蛇毒」以外的怪兽放置毒指示物，并筛选出攻击力因此变为0的怪兽触发破坏事件。
function c54306223.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 获取双方场上所有的怪兽。
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
		-- 触发自定义事件，将攻击力变为0的怪兽组作为事件卡组传入，以触发后续的破坏效果。
		Duel.RaiseEvent(g,EVENT_CUSTOM+54306223,e,0,0,0,0)
	end
end
-- 破坏效果的发动准备，将需要破坏的怪兽设为效果处理对象，并设置破坏的操作信息。
function c54306223.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将触发事件中攻击力变为0的怪兽组设为当前效果的处理对象。
	Duel.SetTargetCard(eg)
	-- 设置效果处理信息，表明该连锁的操作分类为破坏，目标为这些攻击力变为0的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 破坏效果的实际处理，将仍存在于场上的目标怪兽破坏。
function c54306223.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果原因破坏目标怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
