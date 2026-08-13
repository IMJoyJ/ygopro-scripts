--真紅眼の亜黒竜
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把1只「真红眼」怪兽解放的场合可以特殊召唤。这个方法的「真红眼亚黑龙」的特殊召唤1回合只能有1次。
-- ①：这张卡被战斗或者对方的效果破坏的场合，以「真红眼亚黑龙」以外的自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽是「真红眼黑龙」的场合，那个原本攻击力变成2倍。
function c18491580.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应特殊召唤规则效果：这张卡不能通常召唤。从自己的手卡·场上把1只「真红眼」怪兽解放的场合可以特殊召唤。这个方法的「真红眼亚黑龙」的特殊召唤1回合只能有1次。
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
	-- 对应诱发效果：①：这张卡被战斗或者对方的效果破坏的场合，以「真红眼亚黑龙」以外的自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽是「真红眼黑龙」的场合，那个原本攻击力变成2倍。
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
-- 定义特殊召唤规则所用的解放素材过滤函数：要求候选卡是怪兽、属于「真红眼」字段，且解放该卡后自己场上仍有可用的怪兽区空格，以此保证特殊召唤能够成功进行。
function c18491580.hspfilter(c,tp)
	-- 判断候选卡是否满足作为解放素材的条件：必须是「真红眼」怪兽，且解放它后场上仍有空余的怪兽区域。
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3b) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤规则的条件判定：若正在判定的是卡片本身（c为nil）则视为可公开；否则检查自己手卡·场上是否存在1只满足条件的「真红眼」怪兽可供解放，且该解放不是上级召唤所用。
function c18491580.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家tp是否存在至少1只可解放的「真红眼」怪兽（从手卡·场上选取），并确保解放后能满足特殊召唤所需场地空间，同时排除当前要特殊召唤的这张卡本身。
	return Duel.CheckReleaseGroupEx(tp,c18491580.hspfilter,1,REASON_SPSUMMON,true,c,tp)
end
-- 定义特殊召唤规则的处理目标选择：从自己手卡·场上可解放的「真红眼」怪兽中选出1只作为解放对象，并将该对象存入效果标签，供后续解放操作使用；若未选择则发动不成立。
function c18491580.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡·场上所有可解放（非上级召唤用）的怪兽，并筛选出其中满足「真红眼」字段且解放后有空场的候选组。
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(c18491580.hspfilter,c,tp)
	-- 弹出选择提示，让玩家从候选组中选择要解放的卡，提示文本为“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤规则的实际处理：取出之前选定的解放对象并将其解放，完成特殊召唤手续所需的代价。
function c18491580.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将标签中保存的选定怪兽以特殊召唤手续为理由解放。
	Duel.Release(sg,REASON_SPSUMMON)
end
-- 定义①效果的发动条件：这张卡被战斗破坏，或者被对方玩家的效果破坏且破坏前是自己场上表侧存在时，才允许发动。
function c18491580.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 定义①效果选择墓地怪兽的过滤条件：必须是「真红眼」怪兽、等级7以下、不是「真红眼亚黑龙」本身，并且能够被正常特殊召唤。
function c18491580.filter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(7) and not c:IsCode(18491580)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果的发动目标与合法性判定：若选择对象则确认其在自己墓地且满足过滤条件；发动时需自己场上存在可用怪兽区，且墓地存在1只符合条件的「真红眼」怪兽。
function c18491580.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18491580.filter(chkc,e,tp) end
	-- 效果发动时需要确认自己场上至少存在1个可用的主要怪兽区，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时需要确认自己墓地存在至少1张满足条件的「真红眼」怪兽，可以作为取对象特殊召唤的目标。
		and Duel.IsExistingTarget(c18491580.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家从符合条件的墓地怪兽中选择要特殊召唤的对象，提示文本为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足条件的「真红眼」怪兽作为效果对象，并自动将其登记为当前连锁的目标卡。
	local g=Duel.SelectTarget(tp,c18491580.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本连锁将进行1只怪兽的特殊召唤操作，用于时点检测与后续效果联动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义①效果处理：将对象怪兽特殊召唤；若召唤的是「真红眼黑龙」，则为其附加原本攻击力变成2倍的效果。
function c18491580.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出这次效果发动时选择的墓地那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与本次效果相关（未中途离场导致联系中断），并以表侧表示将其特殊召唤到自己的怪兽区；若召唤成功则继续处理后续效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if tc:IsCode(74677422) then
			-- 对应效果原文：这个效果特殊召唤的怪兽是「真红眼黑龙」的场合，那个原本攻击力变成2倍。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(tc:GetBaseAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	-- 结束本次特殊召唤处理，统一结算特殊召唤成功后的时点与诱发效果。
	Duel.SpecialSummonComplete()
end
