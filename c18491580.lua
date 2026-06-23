--真紅眼の亜黒竜
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把1只「真红眼」怪兽解放的场合可以特殊召唤。这个方法的「真红眼亚黑龙」的特殊召唤1回合只能有1次。
-- ①：这张卡被战斗或者对方的效果破坏的场合，以「真红眼亚黑龙」以外的自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽是「真红眼黑龙」的场合，那个原本攻击力变成2倍。
function c18491580.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个效果是特殊召唤规则，允许从手卡或场上解放一只「真红眼」怪兽来特殊召唤此卡，且每回合只能发动一次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18491580+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c18491580.hspcon)
	e1:SetTarget(c18491580.hsptg)
	e1:SetOperation(c18491580.hspop)
	c:RegisterEffect(e1)
	-- 这个效果是当此卡被战斗或对方的效果破坏时，可以将自己墓地一只7星以下的「真红眼」怪兽特殊召唤，若该怪兽是「真红眼黑龙」则其原本攻击力变为2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c18491580.spcon)
	e2:SetTarget(c18491580.sptg)
	e2:SetOperation(c18491580.spop)
	c:RegisterEffect(e2)
end
-- 此函数用于筛选可以被解放用于特殊召唤的「真红眼」怪兽，要求是怪兽卡、属于「真红眼」卡组且场上存在可用怪兽区。
function c18491580.hspfilter(c,tp)
	-- 筛选条件为：是怪兽卡、属于「真红眼」卡组、且场上存在可用怪兽区。
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3b) and Duel.GetMZoneCount(tp,c)>0
end
-- 此函数用于判断是否满足特殊召唤的条件，即是否能从手卡或场上解放一只符合条件的「真红眼」怪兽。
function c18491580.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少一张满足hspfilter条件的卡，用于特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c18491580.hspfilter,1,REASON_SPSUMMON,true,c,tp)
end
-- 此函数用于选择要解放的卡，从满足条件的卡中选择一张。
function c18491580.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡组，并筛选出满足hspfilter条件的卡。
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c18491580.hspfilter,c,tp)
	-- 向玩家发送提示信息，提示选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 此函数用于执行特殊召唤时的解放操作。
function c18491580.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选择的卡进行解放，原因是为了特殊召唤。
	Duel.Release(sg,REASON_SPSUMMON)
end
-- 此函数用于判断是否满足发动特殊召唤效果的条件，即此卡被战斗或对方的效果破坏。
function c18491580.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 此函数用于筛选墓地中可以特殊召唤的「真红眼」怪兽，要求是「真红眼」卡组、等级不超过7、不是此卡本身且可以特殊召唤。
function c18491580.filter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(7) and not c:IsCode(18491580)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 此函数用于设置特殊召唤效果的目标选择，从墓地中选择符合条件的怪兽。
function c18491580.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18491580.filter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区来特殊召唤目标怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c18491580.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽，从墓地中选择一只符合条件的怪兽。
	local g=Duel.SelectTarget(tp,c18491580.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 此函数用于执行特殊召唤效果的操作，包括特殊召唤目标怪兽并处理其攻击力变化。
function c18491580.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效，并尝试特殊召唤该怪兽。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if tc:IsCode(74677422) then
			-- 如果目标怪兽是「真红眼黑龙」，则将其原本攻击力变为2倍。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(tc:GetBaseAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 完成特殊召唤流程，确保所有特殊召唤步骤都已处理完毕。
	Duel.SpecialSummonComplete()
end
