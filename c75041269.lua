--幽獄の時計塔
-- 效果：
-- 对方回合的准备阶段时，这张卡放置1个时计指示物。时计指示物合计有4个以上的场合，这张卡的控制者不会受到战斗伤害。放置有4个以上时计指示物的这张卡被破坏送去墓地时，从手卡·卡组特殊召唤1只「命运英雄 恐惧人」。
function c75041269.initial_effect(c)
	-- 将卡片关联的系列怪兽（命运英雄）注册到列表中，以便相关卡片进行检索或判定。
	aux.AddSetNameMonsterList(c,0xc008)
	c:EnableCounterPermit(0x1b)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方回合的准备阶段时，这张卡放置1个时计指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75041269,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c75041269.ctcon)
	e2:SetOperation(c75041269.ctop)
	c:RegisterEffect(e2)
	-- 时计指示物合计有4个以上的场合，这张卡的控制者不会受到战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c75041269.dcon)
	c:RegisterEffect(e3)
	-- 放置有4个以上时计指示物的这张卡被破坏送去墓地时
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c75041269.regop)
	c:RegisterEffect(e0)
	-- 放置有4个以上时计指示物的这张卡被破坏送去墓地时，从手卡·卡组特殊召唤1只「命运英雄 恐惧人」。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75041269,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c75041269.spcon)
	e4:SetTarget(c75041269.sptg)
	e4:SetOperation(c75041269.spop)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
end
-- 判断这张卡上的时计指示物数量是否在4个以上。
function c75041269.dcon(e)
	return e:GetHandler():GetCounter(0x1b)>=4
end
-- 判断当前是否为对方回合的准备阶段。
function c75041269.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 在对方回合准备阶段给这张卡放置1个时计指示物。
function c75041269.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1b,1)
end
-- 在卡片离开场地的瞬间，检测并记录其上是否存在4个以上的时计指示物。
function c75041269.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCounter(0x1b)>=4 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 判断这张卡是否因破坏被送去墓地，且离场前是否拥有4个以上的时计指示物。
function c75041269.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and e:GetLabelObject():GetLabel()==1
end
-- 过滤手卡或卡组中卡名为「命运英雄 恐惧人」且可以特殊召唤的怪兽。
function c75041269.spfilter(c,e,tp)
	return c:IsCode(40591390) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，声明特殊召唤的操作信息。
function c75041269.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表示该效果会从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的具体处理，从手卡或卡组将1只「命运英雄 恐惧人」特殊召唤。
function c75041269.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者的怪兽区域是否有空位，若无空位则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组中选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c75041269.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽以表侧表示特殊召唤到控制者的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
