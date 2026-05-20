--RR－インペイル・レイニアス
-- 效果：
-- 「急袭猛禽-穿刺伯劳」的②的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。
-- ②：这张卡攻击过的回合的自己主要阶段2，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽特殊召唤。
function c60950180.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60950180,0))  --"表示变更"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c60950180.poscon)
	e1:SetTarget(c60950180.postg)
	e1:SetOperation(c60950180.posop)
	c:RegisterEffect(e1)
	-- 「急袭猛禽-穿刺伯劳」的②的效果1回合只能使用1次。②：这张卡攻击过的回合的自己主要阶段2，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60950180,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,60950180)
	e2:SetCondition(c60950180.spcon)
	e2:SetTarget(c60950180.sptg)
	e2:SetOperation(c60950180.spop)
	c:RegisterEffect(e2)
	if not c60950180.global_check then
		c60950180.global_check=true
		-- 「急袭猛禽-穿刺伯劳」的②的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。②：这张卡攻击过的回合的自己主要阶段2，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetLabel(60950180)
		-- 设置全局效果的操作为给召唤成功的怪兽添加标记
		ge1:SetOperation(aux.sumreg)
		-- 在全局注册该通常召唤检测效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(60950180)
		-- 在全局注册该特殊召唤检测效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果①的发动条件：自身在本回合召唤·特殊召唤成功
function c60950180.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(60950180)>0
end
-- 过滤条件：场上表侧攻击表示且可以改变表示形式的怪兽
function c60950180.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果①的靶向/发动准备：选择场上1只表侧攻击表示怪兽为对象
function c60950180.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c60950180.filter(chkc) end
	-- 判断场上是否存在至少1只符合条件的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c60950180.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60950180.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：改变1张卡的形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的效果处理：将对象怪兽变成表侧守备表示
function c60950180.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽变成表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：这张卡进行过攻击的回合的自己主要阶段2
function c60950180.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身本回合攻击次数大于0且当前为主要阶段2
	return e:GetHandler():GetAttackedCount()>0 and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：自己墓地可以特殊召唤的「急袭猛禽」怪兽
function c60950180.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向/发动准备：选择自己墓地1只「急袭猛禽」怪兽为对象
function c60950180.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c60950180.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只符合条件的「急袭猛禽」怪兽
		and Duel.IsExistingTarget(c60950180.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只符合条件的「急袭猛禽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60950180.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将对象怪兽特殊召唤
function c60950180.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
