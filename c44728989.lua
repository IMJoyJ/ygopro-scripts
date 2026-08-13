--再生の海
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只攻击力1000以下的水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
local s,id,o=GetID()
-- 初始化卡片的两个效果：先注册一个EFFECT_TYPE_ACTIVATE且EVENT_FREE_CHAIN的空效果使这张魔陷能够发动；再注册①的起动效果，设置特殊召唤分类、魔法陷阱区发动、取对象、同名卡1回合1次限制，并指定目标选择与效果处理函数。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只攻击力1000以下的水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
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
-- 过滤函数：筛选自己墓地中攻击力1000以下、水属性，且可以被当前效果特殊召唤的怪兽（检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标合法性与发动条件检查：若在连锁确认对象阶段，验证chkc是自己墓地且满足s.spfilter；若在发动判定阶段，检查己方怪兽区有空位且墓地存在至少1只满足条件的可取对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件之一：己方场上存在可用的怪兽区空格，否则无法发动特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地中至少存在1只可作为效果对象且满足s.spfilter条件（攻击力1000以下・水属性・可特殊召唤）的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在选择对象前向玩家展示“请选择要特殊召唤的卡”的提示信息（HINT_SELECTMSG）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足s.spfilter的怪兽作为效果对象，并通过Duel.SelectTarget自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息登记为特殊召唤分类，对象为已选择的1只怪兽，用于后续规则检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：获取对象怪兽，若对象仍与效果关联，则将其表侧表示特殊召唤到己方场上；成功后用GetFieldID标记该怪兽，并在场上注册一个结束阶段破坏该怪兽的持续效果；最后调用SpecialSummonComplete完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽（从当前连锁中获取第一个目标）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与当前效果关联（未因离场等原因失去联系），并尝试将其以表侧表示进行特殊召唤（作为SpecialSummonStep步骤）。
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
		-- 将用于结束阶段破坏的持续效果注册给当前玩家tp，使其在场上全局生效。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤步骤的结算，正式确定特殊召唤成功并触发相应时点。
	Duel.SpecialSummonComplete()
end
-- 破坏效果的发动条件：对比特殊召唤时记录的FieldID与怪兽当前标记的FieldID；若不一致，说明该怪兽已不是当时的召唤对象，则重置此效果并取消破坏；若一致则允许在结束阶段破坏。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏效果的处理：在结束阶段将特殊召唤的怪兽以效果原因破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行破坏：以“效果”为破坏原因，破坏LabelObject中记录的那只特殊召唤的怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
