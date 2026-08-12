--神速の具足
-- 效果：
-- 自己的抽卡阶段时抽到的卡是名字带有「六武众」的怪兽卡的场合，可以把那张卡给对方观看并在自己场上特殊召唤。
function c84613836.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的抽卡阶段时抽到的卡是名字带有「六武众」的怪兽卡的场合，可以把那张卡给对方观看并在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84613836,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_SZONE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c84613836.spcon)
	e1:SetTarget(c84613836.sptg)
	e1:SetOperation(c84613836.spop)
	c:RegisterEffect(e1)
end
-- 发动条件：检查是否在自己的抽卡阶段抽卡
function c84613836.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为自己抽卡且当前阶段为抽卡阶段
	return ep==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 过滤条件：手牌中未公开的「六武众」怪兽，且可以特殊召唤
function c84613836.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：验证发动条件，给对方确认抽到的「六武众」怪兽并设为效果处理对象
function c84613836.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测可行性阶段，则需自己场上有怪兽区域空位，且抽到的卡中存在满足过滤条件的卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(c84613836.filter,1,nil,e,tp) end
	local g=eg:Filter(c84613836.filter,nil,e,tp)
	if g:GetCount()==1 then
		-- 向对方展示抽到的那张「六武众」怪兽卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身手牌
		Duel.ShuffleHand(tp)
		-- 将该卡设为效果处理的对象
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 向对方展示玩家选择的那张「六武众」怪兽卡
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自身手牌
		Duel.ShuffleHand(tp)
		-- 将选择的卡设为效果处理的对象
		Duel.SetTargetCard(sg)
	end
	-- 设置效果处理信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：将确认的「六武众」怪兽在自己场上特殊召唤
function c84613836.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上已无可用怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取设为效果处理对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
