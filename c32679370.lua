--ヒーロー・キッズ
-- 效果：
-- 这张卡特殊召唤成功时，可以从卡组特殊召唤任意数量的「英雄小子」。
function c32679370.initial_effect(c)
	-- 这张卡特殊召唤成功时，可以从卡组特殊召唤任意数量的「英雄小子」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32679370,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c32679370.target)
	e1:SetOperation(c32679370.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡组中的卡是否为「英雄小子」（卡号32679370），并且是否可以被当前效果特殊召唤（不检查召唤条件、不检查苏生限制）。
function c32679370.filter(c,e,tp)
	return c:IsCode(32679370) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件的判定函数：仅在己方主要怪兽区域存在空位、且卡组中存在至少1张满足条件的「英雄小子」时才允许发动。
function c32679370.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己主要怪兽区域是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1张满足条件的「英雄小子」可供特殊召唤。
		and Duel.IsExistingMatchingCard(c32679370.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息设置为特殊召唤，约定预计处理1张来自卡组的卡，用于后续效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的执行函数：根据主要怪兽区域剩余空位数量，从卡组选择1到空位数量的「英雄小子」进行特殊召唤；若存在【青眼精灵龙】效果，则最多只能特殊召唤1只。
function c32679370.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区域的可用空格数量，用于决定可特殊召唤的卡牌数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选择1到ft张满足条件的「英雄小子」（ft为可用的怪兽区域数量）。
	local g=Duel.SelectMatchingCard(tp,c32679370.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「英雄小子」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
