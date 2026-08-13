--EMドクロバット・ジョーカー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己不是「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- ①：这张卡召唤时才能发动。「娱乐伙伴 骷髅杂技小丑」以外的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽之内任意1只从卡组加入手卡。
function c40318957.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆怪兽属性（灵摆召唤、作为灵摆卡发动），使这张卡获得灵摆召唤相关的设定。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c40318957.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤时才能发动。「娱乐伙伴 骷髅杂技小丑」以外的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽之内任意1只从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40318957,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c40318957.thtg)
	e3:SetOperation(c40318957.thop)
	c:RegisterEffect(e3)
end
-- 定义通用系列筛选条件：卡名属于「娱乐伙伴」怪兽，或是「魔术师」灵摆怪兽，或是「异色眼」怪兽；用于灵摆召唤限制和检索目标判断。
function c40318957.filter(c)
	return c:IsSetCard(0x9f) or (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(0x99)
end
-- 灵摆召唤限制的判定：若被灵摆召唤的怪兽不满足上述系列条件，则禁止该灵摆召唤。
function c40318957.splimit(e,c,tp,sumtp,sumpos)
	return not c40318957.filter(c) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 检索目标的过滤条件：满足系列条件、不是本卡自身、是怪兽且能够加入手卡的卡组内的卡。
function c40318957.thfilter(c)
	return c40318957.filter(c) and not c:IsCode(40318957) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 怪兽效果的发动条件与操作信息设置：发动时确认卡组存在可检索目标，并将本次处理登记为把1张卡从卡组加入手卡。
function c40318957.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张符合条件的检索目标，若不存在则不能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c40318957.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息：预计将1张卡从卡组加入手卡（此时不指定具体卡，由效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：从卡组选择1张符合条件的怪兽加入手卡，并向对手展示所加入的卡。
function c40318957.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示“请选择要加入手牌的卡”的提示信息，等待玩家进行目标选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的怪兽卡，作为本次效果处理的实际检索对象。
	local g=Duel.SelectMatchingCard(tp,c40318957.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，方式为效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对手确认，公开检索到的卡片信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
