--剣闘獣ラクエル
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡的原本攻击力变成2100。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 绳斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c78868776.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡的原本攻击力变成2100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetCondition(c78868776.atkcon)
	e1:SetValue(2100)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 绳斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78868776,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c78868776.spcon)
	e2:SetCost(c78868776.spcost)
	e2:SetTarget(c78868776.sptg)
	e2:SetOperation(c78868776.spop)
	c:RegisterEffect(e2)
end
-- 原本攻击力变更效果的发动条件：检查自身是否带有由「剑斗兽」怪兽效果特殊召唤成功的标记
function c78868776.atkcon(e)
	return e:GetHandler():GetFlagEffect(78868776)>0
end
-- 特殊召唤效果的发动条件：检查自身在本次战斗阶段中是否进行过战斗
function c78868776.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤效果的发动代价：确认自身能否回到卡组，并在发动时将自身送回卡组洗牌
function c78868776.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将自身作为发动代价送回持有者卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：卡组中卡名不为「剑斗兽 绳斗」且可以特殊召唤的「剑斗兽」怪兽
function c78868776.filter(c,e,tp)
	return not c:IsCode(78868776) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位与卡组中是否存在可特殊召唤的怪兽，并设置操作信息
function c78868776.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查时，确认怪兽区域是否有空位（由于自身作为代价离场，空位数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认卡组中是否存在至少1只满足过滤条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c78868776.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的效果处理：从卡组选择1只「剑斗兽」怪兽特殊召唤，并为其注册由「剑斗兽」效果特殊召唤成功的标记
function c78868776.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，确认怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c78868776.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
