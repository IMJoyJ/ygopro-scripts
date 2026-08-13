--アークジェット・ライトクラフター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只8星以下的机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的等级变成9星，效果无效化。
-- ③：只要这张卡在怪兽区域存在，自己不是机械族超量怪兽不能从额外卡组特殊召唤。
function c38173725.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38173725,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38173725.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只8星以下的机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的等级变成9星，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38173725,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,38173725)
	e2:SetTarget(c38173725.sptg)
	e2:SetOperation(c38173725.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，自己不是机械族超量怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(c38173725.splimit)
	c:RegisterEffect(e4)
end
-- 无解放召唤规则效果的条件判定：c==nil时不额外限制（交由系统判断）；实际召唤要求最低解放数minc为0（不解放），此卡等级不低于5星，自己场上没有怪兽，且自己主要怪兽区有空位。
function c38173725.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查自己主要怪兽区不存在任何怪兽，满足“自己场上没有怪兽”的条件。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己主要怪兽区有可用的空格，确保这张卡可以不解放召唤到场上。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 筛选可特殊召唤的对象：等级8以下、机械族，且可以通过本效果由当前玩家以表侧守备表示特殊召唤（同时满足苏生限制等条件）。
function c38173725.spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 取对象效果的目标判定：连锁处理时确认对象仍是自己墓地的满足筛选条件的机械族怪兽；发动时确认自己主要怪兽区有空位，并且墓地存在至少1只这样的怪兽可作为对象。
function c38173725.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38173725.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区有空格，才能把对象怪兽特殊召唤到场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足spfilter筛选条件、且能被本效果取为对象的机械族怪兽。
		and Duel.IsExistingTarget(c38173725.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的筛选结果中选择1只机械族怪兽，并设为这个取对象效果的对象。
	local g=Duel.SelectTarget(tp,c38173725.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将当前连锁的操作信息登记为：特殊召唤已选定的1只怪兽，供效果处理及后续判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象怪兽；若对象仍与效果关联且可以特殊召唤，则先以表侧守备表示执行特殊召唤步骤；随后让该怪兽的效果无效化、等级变成9星，最后调用SpecialSummonComplete完成特殊召唤并触发召唤成功时点。
function c38173725.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中本效果登记的对象卡（此前从墓地选择的机械族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与这个效果有联系，并且能够被当前玩家以表侧守备表示特殊召唤；成立则执行该怪兽的特殊召唤步骤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 这个效果特殊召唤的怪兽的等级变成9星。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(9)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 结束分批特殊召唤处理，使前面SpecialSummonStep的怪兽正式特殊召唤成功，并触发召唤成功时的各类时点。
	Duel.SpecialSummonComplete()
end
-- 自肃限制的判定函数：被特殊召唤的怪兽位于额外卡组，且不是机械族超量怪兽时返回真，即禁止这次特殊召唤；自己从额外卡组只能特殊召唤机械族超量怪兽。
function c38173725.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ))
end
