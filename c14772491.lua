--魂の共有－コモンソウル
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。自己手卡的1只名字带有「新空间侠」的怪兽在选择怪兽的控制者的场上特殊召唤。选择怪兽的攻击力上升这个效果特殊召唤的名字带有「新空间侠」的怪兽的攻击力数值。这张卡从场上离开时，这张卡的效果特殊召唤的1只名字带有「新空间侠」的怪兽回到手卡。
function c14772491.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽发动。自己手卡的1只名字带有「新空间侠」的怪兽在选择怪兽的控制者的场上特殊召唤。选择怪兽的攻击力上升这个效果特殊召唤的名字带有「新空间侠」的怪兽的攻击力数值。
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
-- 定义特殊召唤筛选函数：手牌怪兽须为「新空间侠」（0x1f），且能够以表侧表示特殊召唤到目标怪兽控制者（cp）的场上。
function c14772491.spfilter(c,e,tp,cp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,cp)
end
-- 定义对象筛选函数：候选怪兽须表侧表示，其控制者场上存在可用怪兽区空格，并且自己手牌中有至少1只满足 spfilter 的「新空间侠」怪兽可以特殊召唤到该控制者场上。
function c14772491.filter(c,e,tp)
	-- 检查候选怪兽为表侧表示，且其控制者场上怪兽区有空位。
	return c:IsFaceup() and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己手牌中存在至少1只可经由 spfilter 判定、能特殊召唤到对象怪兽控制者场上的「新空间侠」怪兽。
		and Duel.IsExistingMatchingCard(c14772491.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetControler())
end
-- 发动时的目标选择函数：在发动阶段选取场上1只表侧表示怪兽为对象，并设定特殊召唤相关操作信息；同时在连锁确认时验证所选对象合法。
function c14772491.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14772491.filter(chkc,e,tp) end
	-- 发动合法性检查：场上是否存在满足 filter 条件的表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c14772491.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 弹出选择提示，让玩家从场上选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 将玩家选择的1只表侧表示怪兽设为该效果的对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c14772491.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置本次效果的操作信息：将从手牌特殊召唤1只怪兽（区域为手牌，数量为1），供其他卡片和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：取得对象怪兽及其控制者；若魂之共有和对象怪兽仍合法且对象怪兽仍在场表侧表示，则从手牌选择1只「新空间侠」怪兽特殊召唤到对象控制者场上，给对象怪兽施加攻击力上升效果并记录关联。
function c14772491.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local cp=tc:GetControler()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 如果对象怪兽控制者场上没有可用的怪兽区空格，则效果不适用，直接结束处理。
		if Duel.GetLocationCount(cp,LOCATION_MZONE)<=0 then return end
		-- 弹出选择提示，让玩家从手牌选择要特殊召唤的「新空间侠」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手牌中选择1只满足 spfilter 的「新空间侠」怪兽，用于特殊召唤到对象控制者场上。
		local g=Duel.SelectMatchingCard(tp,c14772491.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,cp)
		if g:GetCount()==0 then return end
		local sc=g:GetFirst()
		-- 将选中的怪兽以表侧表示特殊召唤到对象控制者（cp）的场上。
		Duel.SpecialSummon(sc,0,tp,cp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
		c:SetCardTarget(sc)
		e:GetLabelObject():SetLabelObject(sc)
		-- 选择怪兽的攻击力上升这个效果特殊召唤的名字带有「新空间侠」的怪兽的攻击力数值。这张卡从场上离开时，这张卡的效果特殊召唤的1只名字带有「新空间侠」的怪兽回到手卡。
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
-- 攻击力上升效果的持续条件：魂之共有仍同时以攻击力上升的对象怪兽和特殊召唤的「新空间侠」怪兽为永续对象，即两者之间的关联仍然存在。
function c14772491.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
		and e:GetOwner():IsHasCardTarget(e:GetLabelObject())
end
-- 离场返回效果的发动条件：记录的特殊召唤「新空间侠」怪兽仍在场上表侧表示，且魂之共有仍以它为永续对象，同时魂之共有本身离场。
function c14772491.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and tc:IsOnField() and tc:IsFaceup() and tc:IsSetCard(0x1f)
		and e:GetHandler():IsHasCardTarget(tc)
end
-- 离场返回效果的处理：将记录的特殊召唤「新空间侠」怪兽送回持有者手牌。
function c14772491.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将记录的那只「新空间侠」怪兽以效果原因送回持有者手牌。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
