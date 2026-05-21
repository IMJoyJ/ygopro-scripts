--ウィジャ盤
-- 效果：
-- 这张卡和「死之信息」卡4种类在自己场上齐集时，自己决斗胜利。
-- ①：对方结束阶段把这个效果发动。从手卡·卡组让1张「死之信息」卡以「E」「A」「T」「H」的顺序在自己的魔法与陷阱区域出现。
-- ②：自己场上的「通灵盘」或者「死之信息」卡从场上离开时自己场上的「通灵盘」以及「死之信息」卡全部送去墓地。
function c94212438.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：对方结束阶段把这个效果发动。从手卡·卡组让1张「死之信息」卡以「E」「A」「T」「H」的顺序在自己的魔法与陷阱区域出现。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94212438,0))  --"让「死之信息」卡出现"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(94212438)
	e2:SetCondition(c94212438.plcon)
	e2:SetOperation(c94212438.plop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「通灵盘」或者「死之信息」卡从场上离开时自己场上的「通灵盘」以及「死之信息」卡全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c94212438.tgcon)
	e3:SetOperation(c94212438.tgop)
	c:RegisterEffect(e3)
	-- ②：自己场上的「通灵盘」或者「死之信息」卡从场上离开时自己场上的「通灵盘」以及「死之信息」卡全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c94212438.tgop)
	c:RegisterEffect(e4)
	-- 这张卡和「死之信息」卡4种类在自己场上齐集时，自己决斗胜利。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_ONFIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetOperation(c94212438.winop)
	c:RegisterEffect(e5)
end
-- ①效果的发动条件判定：必须在对方回合的结束阶段，且通灵盘上放置的死之信息卡数量小于4张，且通灵盘处于已适用状态
function c94212438.plcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方，且通灵盘已放置的死之信息卡数量（通过Flag计数）小于4张
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetFlagEffect(94212438)<4
		and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 过滤函数：检索卡名与当前需要放置的死之信息卡卡号相同、且未被禁止使用的卡
function c94212438.plfilter(c,id)
	return c:IsCode(id) and not c:IsForbidden()
end
-- ①效果的处理：根据当前进度确定要放置的死之信息卡，并根据「暗黑圣域」的效果决定是将其作为怪兽特殊召唤还是直接放置在魔陷区
function c94212438.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ids={31893528,67287533,94772232,30170981}
	local id=ids[c:GetFlagEffect(94212438)+1]
	-- 检查玩家是否受到「暗黑圣域」效果影响，且自己场上有可用的怪兽区域空格
	local res=Duel.IsPlayerAffectedByEffect(tp,16625614) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将该死之信息卡作为怪兽（1星/暗属性/恶魔族/攻0/守0）特殊召唤到场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,SUMMON_VALUE_DARK_SANCTUARY)
	-- 若魔陷区没有空位，且不满足通过「暗黑圣域」特殊召唤的条件，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 and not res then return end
	-- 给玩家发送提示信息，要求选择要出现的死之信息卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(94212438,1))  --"请选择要出现在魔法与陷阱卡区域的卡"
	-- 从手卡或卡组中选择1张满足条件的对应死之信息卡
	local g=Duel.SelectMatchingCard(tp,c94212438.plfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,id)
	local tc=g:GetFirst()
	-- 若成功选出卡片且满足「暗黑圣域」的特招条件，则让玩家选择是否将其作为怪兽特殊召唤
	if tc and res and Duel.SelectYesNo(tp,aux.Stringid(16625614,0)) then  --"是否作为通常怪兽特殊召唤？"
		tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_FIEND,1,0,0)
		-- 将该死之信息卡作为怪兽，以「暗黑圣域」的特殊召唤标记，表侧表示特殊召唤到场上（分解步骤）
		Duel.SpecialSummonStep(tc,SUMMON_VALUE_DARK_SANCTUARY,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的卡不受「暗黑圣域」以外的卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c16625614.efilter)
		e1:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e1)
		-- 不能被选择作为攻击对象
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		c:RegisterFlagEffect(94212438,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 若不作为怪兽特殊召唤，且自己魔陷区有空位
	elseif tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 则将该死之信息卡表侧表示移动到魔法与陷阱区域，并适用其效果
		and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		c:RegisterFlagEffect(94212438,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 过滤函数：检查离开场上的卡是否属于自己场上的「通灵盘」或「死之信息」卡
function c94212438.cfilter1(c,tp)
	return c:IsControler(tp) and (c:IsCode(94212438) or c:IsSetCard(0x1c))
end
-- 过滤函数：用于筛选场上表侧表示的「通灵盘」或「死之信息」卡
function c94212438.cfilter2(c)
	return c:IsFaceup() and (c:IsCode(94212438) or c:IsSetCard(0x1c))
end
-- ②效果的触发条件：检查离场的卡中是否存在自己场上的「通灵盘」或「死之信息」卡
function c94212438.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94212438.cfilter1,1,nil,tp)
end
-- ②效果的处理：将自己场上所有的「通灵盘」以及「死之信息」卡全部送去墓地
function c94212438.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「通灵盘」以及「死之信息」卡
	local g=Duel.GetMatchingGroup(c94212438.cfilter2,tp,LOCATION_ONFIELD,0,nil)
	-- 将获取到的卡片因效果全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 过滤函数：筛选自己场上表侧表示的「死之信息」卡
function c94212438.cfilter3(c)
	return c:IsFaceup() and c:IsSetCard(0x1c)
end
-- 胜利条件判定：当自己场上集齐4种「死之信息」卡且存在「通灵盘」时，宣告决斗胜利
function c94212438.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_DESTINY_BOARD=0x15
	-- 获取自己场上除「通灵盘」自身以外的所有表侧表示的「死之信息」卡
	local g=Duel.GetMatchingGroup(c94212438.cfilter3,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if g:GetClassCount(Card.GetCode)==4 then
		-- 使当前玩家以「通灵盘」的效果获得决斗胜利
		Duel.Win(tp,WIN_REASON_DESTINY_BOARD)
	end
end
