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
-- 过滤函数，用于判断对方场上是否存在有捕食指示物且可因特殊召唤而解放的怪兽。
function c22138839.rfilter(c)
	return c:GetCounter(0x1041)>0 and c:IsReleasable(REASON_SPSUMMON)
end
-- 效果条件函数，判断是否满足特殊召唤的条件：场上存在空位且对方场上存在有捕食指示物的怪兽。
function c22138839.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的怪兽区域是否存在空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方场上是否存在至少1只带有捕食指示物的怪兽。
		and Duel.IsExistingMatchingCard(c22138839.rfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果目标函数，选择对方场上一只带有捕食指示物的怪兽进行解放。
function c22138839.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有带有捕食指示物的怪兽组成的卡片组。
	local g=Duel.GetMatchingGroup(c22138839.rfilter,tp,0,LOCATION_MZONE,nil)
	-- 向玩家发送提示信息，提示其选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 效果处理函数，执行特殊召唤时的解放操作。
function c22138839.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽解放，原因设为特殊召唤。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 效果发动条件函数，判断此卡是否从场上送去墓地。
function c22138839.ccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果处理函数，将对方场上所有表侧表示的怪兽各放置1个捕食指示物，并将等级为2星以上的怪兽等级变为1星。
function c22138839.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有可以放置捕食指示物的怪兽组成的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1041,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 创建一个等级变更效果，使怪兽等级变为1星。
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
-- 等级变更效果的发动条件，判断该怪兽是否带有捕食指示物。
function c22138839.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
