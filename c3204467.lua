--ワーム・ソリッド
-- 效果：
-- 这张卡的守备力上升自己墓地存在的名字带有「异虫」的爬虫类族怪兽数量×100的数值。这张卡被攻击，对方玩家受到战斗伤害的场合，那个伤害步骤结束时把对方场上存在的1张魔法或者陷阱卡破坏。
function c3204467.initial_effect(c)
	-- 这张卡的守备力上升自己墓地存在的名字带有「异虫」的爬虫类族怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c3204467.defval)
	c:RegisterEffect(e1)
	-- 这张卡被攻击，对方玩家受到战斗伤害的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCode(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c3204467.regop)
	c:RegisterEffect(e2)
	-- 那个伤害步骤结束时把对方场上存在的1张魔法或者陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3204467,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c3204467.descon)
	e3:SetTarget(c3204467.destg)
	e3:SetOperation(c3204467.desop)
	c:RegisterEffect(e3)
end
-- 筛选自己墓地中卡名带有「异虫」且种族为爬虫类族的怪兽，作为守备力上升值的计算对象。
function c3204467.vfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
-- 计算此卡守备力的上升值：统计自己墓地中满足条件的「异虫」爬虫类族怪兽数量并乘以100，将此值赋予永续效果。
function c3204467.defval(e,c)
	-- 统计自己墓地中满足vfilter条件的「异虫」爬虫类族怪兽数量，乘以100后作为守备力上升数值。
	return Duel.GetMatchingGroupCount(c3204467.vfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
-- 连续效果处理：当此卡在场且发生战斗伤害事件时，若此卡是被攻击的怪兽，则给此卡注册一个伤害阶段内有效的标记，用于记录“被攻击且对方受到战斗伤害”的条件。
function c3204467.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断本卡是否为这次战斗的被攻击对象，以确保是“这张卡被攻击”的情况。
	if c==Duel.GetAttackTarget() then
		c:RegisterFlagEffect(3204467,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 破坏效果的发动条件：本卡持有之前记录“被攻击且造成战斗伤害”的标记，且伤害步骤结束时仍满足战斗相关条件（未离场或处于战斗破坏状态），才能发动破坏效果。
function c3204467.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本卡是否拥有标记3204467（表示已满足“被攻击且对方受到战斗伤害”），并且aux.dsercon确认伤害步骤结束时仍满足条件；两者同时为真时才允许发动。
	return e:GetHandler():GetFlagEffect(3204467) and aux.dsercon(e,tp,eg,ep,ev,re,r,rp)
end
-- 筛选可以作为破坏对象的卡：场上存在的魔法或陷阱卡（包括里侧表示的魔法陷阱）。
function c3204467.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标处理：选择对方场上1张魔法或陷阱卡作为对象，并设定本次连锁的操作信息为破坏处理。
function c3204467.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c3204467.desfilter(chkc) end
	if chk==0 then return true end
	-- 显示选择提示，让当前玩家从符合条件的目标中选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从对方场上选择1张魔法或陷阱卡作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c3204467.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定操作信息：将本次效果处理标记为破坏，目标为所选对象，数量为所选对象的张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取出之前选择的对象卡，若该卡仍然与效果相关，则将其破坏。
function c3204467.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中通过Duel.SelectTarget选择的对象卡，也就是要破坏的那张魔法/陷阱卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
