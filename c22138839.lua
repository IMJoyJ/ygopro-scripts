--捕食植物バンクシアオーガ
-- 效果：
-- ①：这张卡把对方场上1只有捕食指示物放置的怪兽解放的场合可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合发动。给对方场上的表侧表示怪兽全部各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
function c22138839.initial_effect(c)
	-- ①：这张卡把对方场上1只有捕食指示物放置的怪兽解放的场合可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c22138839.hspcon)
	e1:SetTarget(c22138839.hsptg)
	e1:SetOperation(c22138839.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合发动。给对方场上的表侧表示怪兽全部各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c22138839.ccon)
	e2:SetOperation(c22138839.cop)
	c:RegisterEffect(e2)
end
c22138839.mentioned_counter={
	[0x1041]=true,
}
-- 定义一个过滤函数，用于筛选拥有捕食指示物且可因特殊召唤而被解放的怪兽。
function c22138839.rfilter(c)
	return c:GetCounter(0x1041)>0 and c:IsReleasable(REASON_SPSUMMON)
end
-- 判断是否满足特殊召唤条件，即己方场上存在可用区域，并且对方场上有至少一只带有捕食指示物的怪兽可以被解放。
function c22138839.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方主要怪兽区是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认对方场上是否存在满足条件（带捕食指示物并可因特殊召唤而被解放）的怪兽。
		and Duel.IsExistingMatchingCard(c22138839.rfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 选择并标记一个符合条件的对方怪兽作为解放目标，用于后续处理。
function c22138839.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件（带捕食指示物且可因特殊召唤而被解放）的对方怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c22138839.rfilter,tp,0,LOCATION_MZONE,nil)
	-- 向玩家发送提示信息“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作，将之前选定的目标怪兽进行解放处理。
function c22138839.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际执行对目标怪兽的解放动作，原因设定为特殊召唤。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断该卡是否是从场上送去墓地（而非其他方式如返回手牌等）。
function c22138839.ccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 当此卡因特殊召唤被解放时发动的效果处理，给对方所有表侧表示怪兽放置一个捕食指示物，并将等级高于2的怪兽等级变为1星。
function c22138839.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取所有可以添加捕食指示物的对方场上表侧表示怪兽组成的集合。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1041,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c22138839.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
-- 判断目标怪兽是否带有捕食指示物，用于决定是否触发等级变更效果。
function c22138839.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
