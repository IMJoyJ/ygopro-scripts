--エーリアン・テレパス
-- 效果：
-- 可以把对方怪兽放置的A指示物取除1个，场上1张魔法或者陷阱卡破坏。这个效果1回合只能使用1次。放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
function c91070115.initial_effect(c)
	-- 可以把对方怪兽放置的A指示物取除1个，场上1张魔法或者陷阱卡破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91070115,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c91070115.descost)
	e1:SetTarget(c91070115.destg)
	e1:SetOperation(c91070115.desop)
	c:RegisterEffect(e1)
	-- 放置有A指示物的怪兽和名字带有「外星」的怪兽战斗的场合，每有1个A指示物攻击力·守备力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c91070115.adcon)
	e2:SetTarget(c91070115.adtg)
	e2:SetValue(c91070115.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
c91070115.mentioned_counter={
	[0x100e]=true,
}
-- 破坏效果Cost处理：取除1个A指示物
function c91070115.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：对方场上存在可取除的A指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,0,1,0x100e,1,REASON_COST) end
	-- 取除对方场上的1个A指示物
	Duel.RemoveCounter(tp,0,1,0x100e,1,REASON_COST)
end
-- 破坏目标过滤：魔法·陷阱卡
function c91070115.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果发动准备与目标确认
function c91070115.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c91070115.filter(chkc) end
	-- 发动条件检查：场上存在可选择的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c91070115.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c91070115.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏选中的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：破坏目标卡
function c91070115.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 攻击力·守备力下降效果发动条件：伤害姿势计算阶段且存在战斗对象
function c91070115.adcon(e)
	-- 判断当前是否处于伤害计算阶段且存在战斗对象
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
-- 攻守下降目标过滤：有A指示物且战斗对象为「外星」怪兽
function c91070115.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(0x100e)~=0 and bc:IsSetCard(0xc)
end
-- 计算攻击力·守备力下降数值（每个A指示物下降300）
function c91070115.adval(e,c)
	return c:GetCounter(0x100e)*-300
end
