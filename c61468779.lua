--地霊神グランソイル
-- 效果：
-- 这张卡不能通常召唤。自己墓地的地属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
function c61468779.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的地属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c61468779.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功时，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61468779,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,61468779)
	e3:SetTarget(c61468779.sptg)
	e3:SetOperation(c61468779.spop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c61468779.leaveop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：自己场上有可用的怪兽区域，且自己墓地的地属性怪兽数量刚好为5只
function c61468779.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己墓地的地属性怪兽数量是否刚好为5只
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_EARTH)==5
end
-- 过滤函数：选择可以特殊召唤的怪兽
function c61468779.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查是否满足发动条件，并选择墓地的一只怪兽作为对象
function c61468779.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c61468779.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c61468779.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择双方墓地的一只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61468779.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽在自己场上特殊召唤
function c61468779.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的效果处理：表侧表示的这张卡离场时，注册跳过下次自己回合战斗阶段的效果
function c61468779.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合是否为自己的回合
	if Duel.GetTurnPlayer()==effp then
		-- 将当前回合数记录在效果的Label中，用于后续判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c61468779.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 给玩家注册跳过战斗阶段的效果
	Duel.RegisterEffect(e1,effp)
end
-- 跳过战斗阶段效果的条件函数：当前回合数不等于离场时的回合数（确保在“下次”自己回合生效）
function c61468779.skipcon(e)
	-- 检查当前回合数是否不等于记录的回合数，以确保不在当前回合立即生效
	return Duel.GetTurnCount()~=e:GetLabel()
end
