--アストラグールズ
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
-- ②：1回合1次，自己主要阶段才能发动。掷1次骰子。自己场上的全部表侧表示怪兽的等级直到回合结束时变成和出现的数目相同。
function c69170403.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69170403,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c69170403.sptg)
	e1:SetOperation(c69170403.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。掷1次骰子。自己场上的全部表侧表示怪兽的等级直到回合结束时变成和出现的数目相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69170403,1))
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c69170403.dctg)
	e2:SetOperation(c69170403.dcop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地等级4以下且可以守备表示特殊召唤的怪兽
function c69170403.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与目标选择
function c69170403.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c69170403.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的怪兽可以作为效果对象
		and Duel.IsExistingTarget(c69170403.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69170403.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理（特殊召唤目标怪兽，并使其效果无效化，注册结束阶段除外的延迟效果）
function c69170403.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍与效果相关，并尝试将其以表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(69170403,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c69170403.rmcon)
		e3:SetOperation(c69170403.rmop)
		-- 将结束阶段除外的延迟效果注册给玩家
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤的后续处理（刷新场上状态）
	Duel.SpecialSummonComplete()
end
-- 检查除外效果的触发条件，若目标怪兽已失去标记则重置该效果
function c69170403.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(69170403)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的执行函数
function c69170403.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽表侧表示除外
	Duel.Remove(e:GetLabelObject(),POS_FACEUP,REASON_EFFECT)
end
-- 过滤自己场上表侧表示且拥有等级的怪兽
function c69170403.dcfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 效果②的发动准备
function c69170403.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且有等级的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69170403.dcfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁信息，表示该效果包含掷1次骰子的操作
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果②的处理（掷1次骰子，并将自己场上所有表侧表示怪兽的等级变成出现的数目）
function c69170403.dcop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家掷1次骰子，并获取出现的数目
	local dc=Duel.TossDice(tp,1)
	-- 获取自己场上所有表侧表示且有等级的怪兽
	local g=Duel.GetMatchingGroup(c69170403.dcfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部表侧表示怪兽的等级直到回合结束时变成和出现的数目相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(dc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
