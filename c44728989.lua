--再生の海
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只攻击力1000以下的水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，允许其在自由时点发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只攻击力1000以下的水属性怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤目标怪兽的过滤条件：攻击力不超过1000、水属性、可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理特殊召唤效果的发动条件判断，检查是否有满足条件的墓地怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的水属性怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，并注册结束阶段破坏效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 判断选择的怪兽是否仍然在场且可特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=tc:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		-- 将结束阶段破坏效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤流程的收尾工作
	Duel.SpecialSummonComplete()
end
-- 判断是否为该怪兽对应的结束阶段破坏效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行怪兽的破坏处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽因效果而破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
