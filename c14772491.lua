--魂の共有－コモンソウル
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。自己手卡的1只名字带有「新空间侠」的怪兽在选择怪兽的控制者的场上特殊召唤。选择怪兽的攻击力上升这个效果特殊召唤的名字带有「新空间侠」的怪兽的攻击力数值。这张卡从场上离开时，这张卡的效果特殊召唤的1只名字带有「新空间侠」的怪兽回到手卡。
function c14772491.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14772491.target)
	e1:SetOperation(c14772491.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，这张卡的效果特殊召唤的1只名字带有「新空间侠」的怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c14772491.thcon)
	e2:SetOperation(c14772491.thop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 过滤函数，用于判断手卡中是否满足条件的「新空间侠」怪兽
function c14772491.spfilter(c,e,tp,cp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,cp)
end
-- 过滤函数，用于判断场上是否满足条件的怪兽
function c14772491.filter(c,e,tp)
	-- 目标怪兽必须表侧表示
	return c:IsFaceup() and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 自己手卡必须存在至少1只名字带有「新空间侠」的怪兽
		and Duel.IsExistingMatchingCard(c14772491.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetControler())
end
-- 处理效果的发动选择目标阶段
function c14772491.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14772491.filter(chkc,e,tp) end
	-- 检查是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(c14772491.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c14772491.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将特殊召唤名字带有「新空间侠」的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果的发动执行阶段
function c14772491.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local cp=tc:GetControler()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 判断目标怪兽控制者场上是否有空位
		if Duel.GetLocationCount(cp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的「新空间侠」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择要特殊召唤的「新空间侠」怪兽
		local g=Duel.SelectMatchingCard(tp,c14772491.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,cp)
		if g:GetCount()==0 then return end
		local sc=g:GetFirst()
		-- 将选择的「新空间侠」怪兽特殊召唤到目标怪兽控制者场上
		Duel.SpecialSummon(sc,0,tp,cp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
		c:SetCardTarget(sc)
		e:GetLabelObject():SetLabelObject(sc)
		-- 为选择的怪兽添加攻击力变化效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_OWNER_RELATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetCondition(c14772491.rcon)
		e1:SetValue(sc:GetAttack())
		e1:SetLabelObject(sc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 判断攻击力变化效果是否适用
function c14772491.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
		and e:GetOwner():IsHasCardTarget(e:GetLabelObject())
end
-- 判断是否满足将特殊召唤的怪兽送回手卡的条件
function c14772491.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsOnField() and tc:IsFaceup() and tc:IsSetCard(0x1f)
		and e:GetHandler():IsHasCardTarget(tc)
end
-- 将特殊召唤的怪兽送回手卡
function c14772491.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽送回手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
