--EMドクロバット・ジョーカー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己不是「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- ①：这张卡召唤时才能发动。「娱乐伙伴 骷髅杂技小丑」以外的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽之内任意1只从卡组加入手卡。
function c40318957.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- 自己不是「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c40318957.splimit)
	c:RegisterEffect(e2)
	-- 这张卡召唤时才能发动。「娱乐伙伴 骷髅杂技小丑」以外的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽之内任意1只从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40318957,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c40318957.thtg)
	e3:SetOperation(c40318957.thop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于判断卡片是否为「娱乐伙伴」怪兽、「魔术师」灵摆怪兽或「异色眼」怪兽
function c40318957.filter(c)
	return c:IsSetCard(0x9f) or (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(0x99)
end
-- 限制灵摆召唤的条件，只有满足过滤条件的怪兽才能进行灵摆召唤
function c40318957.splimit(e,c,tp,sumtp,sumpos)
	return not c40318957.filter(c) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 定义检索手牌的过滤函数，用于筛选符合条件的怪兽卡
function c40318957.thfilter(c)
	return c40318957.filter(c) and not c:IsCode(40318957) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查卡组中是否存在满足条件的卡片
function c40318957.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c40318957.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡组中的卡片数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，选择并把符合条件的卡片加入手牌
function c40318957.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c40318957.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
