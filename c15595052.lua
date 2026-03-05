--封魔の伝承者
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，宣言和自己墓地存在的「封魔之传承者」同数目的属性。这张卡对宣言属性的怪兽进行攻击的场合，不进行伤害计算直接破坏那只怪兽。
function c15595052.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，宣言和自己墓地存在的「封魔之传承者」同数目的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15595052,0))  --"宣言属性"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c15595052.ancop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组
function c15595052.ancop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算玩家场上墓地里「封魔之传承者」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,15595052)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 向玩家提示选择属性
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让玩家从可选属性中宣言指定数量的属性
		local att=Duel.AnnounceAttribute(tp,ct,ATTRIBUTE_ALL)
		e:GetHandler():SetHint(CHINT_ATTRIBUTE,att)
		-- 这张卡对宣言属性的怪兽进行攻击的场合，不进行伤害计算直接破坏那只怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(15595052,1))  --"破坏"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetTarget(c15595052.destg)
		e1:SetOperation(c15595052.desop)
		e1:SetLabel(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足破坏条件
function c15595052.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取攻击对手的怪兽
	local bc=Duel.GetAttackTarget()
	-- 检查攻击怪兽是否为宣言属性
	if chk==0 then return c==Duel.GetAttacker() and bc and bc:IsFaceup() and bc:IsAttribute(e:GetLabel()) end
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 执行破坏操作
function c15595052.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对手的怪兽
	local bc=Duel.GetAttackTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
