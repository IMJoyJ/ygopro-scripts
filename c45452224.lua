--金華猫
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转时，以自己墓地1只1星怪兽为对象才能发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽除外。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c45452224.initial_effect(c)
	-- 为这张卡注册灵魂怪兽通用的结束阶段回手效果：这张卡在召唤成功或反转的回合的结束阶段发动，回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为false，使这张卡永远不满足特殊召唤条件，从而禁止以任何方式特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转时，以自己墓地1只1星怪兽为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(45452224,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c45452224.sptg)
	e4:SetOperation(c45452224.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
	-- 这张卡从场上离开时那只怪兽除外。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetOperation(c45452224.leave)
	c:RegisterEffect(e6)
	e4:SetLabelObject(e6)
	e5:SetLabelObject(e6)
end
-- 定义墓地怪兽的筛选条件：对象必须为1星怪兽，且能被当前效果特殊召唤（满足苏生限制与召唤条件）。
function c45452224.filter(c,e,tp)
	return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性判断：处理连锁确认对象时，校验对象位于自己墓地且为1星可特殊召唤怪兽；发动确认时，检查自己主要怪兽区有空位且墓地存在1只以上符合条件的对象。
function c45452224.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45452224.filter(chkc,e,tp) end
	-- 发动合法性检查的第一步：自己主要怪兽区域必须存在可用空格，以确保能够特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查的第二步：自己墓地存在至少1只满足筛选条件的1星怪兽（1星且可特殊召唤），可作为效果对象。
		and Duel.IsExistingTarget(c45452224.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在选择特殊召唤对象前，向当前玩家显示‘请选择要特殊召唤的卡’的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从自己墓地选择1只符合条件的1星怪兽作为效果对象，并将该卡设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c45452224.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本效果含有特殊召唤，且对象为已选择的1只怪兽；用于后续时点/连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取出对象怪兽并将其表侧表示特殊召唤；若召唤成功且本卡仍与效果关联，则建立本卡与对象怪兽的永续联系，用于离场时除外。
function c45452224.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果处理的对象怪兽（即从墓地选择的那只1星怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 条件判断：对象怪兽仍与效果关联、特殊召唤成功（返回>0）、且本卡仍与效果关联时，才继续执行后续关联设置。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		e:GetLabelObject():SetLabelObject(tc)
		c:CreateRelation(tc,RESET_EVENT+0x5020000)
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
	end
end
-- 离场处理函数：当本卡从场上离开时，检查本卡与对象怪兽的关联仍然存在，若存在则将对象怪兽除外。
function c45452224.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		-- 以效果原因将对象怪兽表侧表示除外，实现‘这张卡从场上离开时那只怪兽除外’的处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
