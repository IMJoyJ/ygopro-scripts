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
-- 过滤函数：筛选对方场上放置有捕食指示物且可以为特殊召唤而解放的怪兽。
function c22138839.rfilter(c)
	return c:GetCounter(0x1041)>0 and c:IsReleasable(REASON_SPSUMMON)
end
-- 特殊召唤规则的条件：确认自己主要怪兽区有空格，且对方场上存在可解放的捕食指示物怪兽。
function c22138839.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己的主要怪兽区有1个以上的可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认对方场上至少存在1只放置有捕食指示物且可以解放的怪兽。
		and Duel.IsExistingMatchingCard(c22138839.rfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤规则的对象选择：从对方场上有捕食指示物的怪兽中选择1只作为解放对象，并记录到效果标签中。
function c22138839.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索对方场上所有放置有捕食指示物且可以解放的怪兽，组成候选卡集合。
	local g=Duel.GetMatchingGroup(c22138839.rfilter,tp,0,LOCATION_MZONE,nil)
	-- 向玩家显示"请选择要解放的卡"的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理：将之前选中的那只怪兽解放，作为从手卡特殊召唤的手续。
function c22138839.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的原因解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ②效果的发动条件：这张卡从场上送去墓地的场合（确认之前所在位置是场上）。
function c22138839.ccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的处理：给对方场上所有可以放置捕食指示物的表侧表示怪兽各放置1个捕食指示物，并对其中2星以上的怪兽注册等级变成1星的效果。
function c22138839.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索对方场上所有可以放置捕食指示物的表侧表示怪兽。
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
-- 等级变更效果的适用条件：该怪兽上放置有捕食指示物。
function c22138839.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
