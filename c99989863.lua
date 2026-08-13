--刻まれし魔の楽園
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只7星以上的恶魔族·光属性怪兽为对象才能发动。那只怪兽以外的场上的卡全部送去墓地。
-- ②：这张卡在墓地存在的状态，对方把怪兽特殊召唤的场合，把这张卡除外才能发动。从卡组·额外卡组把1只「刻魔」怪兽送去墓地。
local s,id,o=GetID()
-- 创建并注册两个效果：①效果为魔法卡发动时取对象送墓；②效果为墓地中对方特殊召唤怪兽时除外自身并从卡组·额外卡组送墓「刻魔」怪兽。
function s.initial_effect(c)
	-- ①：以自己场上1只7星以上的恶魔族·光属性怪兽为对象才能发动。那只怪兽以外的场上的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方把怪兽特殊召唤的场合，把这张卡除外才能发动。从卡组·额外卡组把1只「刻魔」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组额外卡组送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tgcon2)
	-- 设置②效果的发动COST为把墓地中的这张卡除外（aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg2)
	e2:SetOperation(s.tgop2)
	c:RegisterEffect(e2)
end
-- 定义①效果取对象的筛选条件：自己场上表侧表示、7星以上、恶魔族·光属性怪兽，且场上还存在除该对象以外能被送去墓地的卡。
function s.filter(c,tp)
	-- 怪兽必须是表侧表示、等级7以上、恶魔族、光属性，并且场上存在该怪兽以外可送去墓地的卡。
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 定义①效果的发动时点处理：选择符合条件的对象，并获取对象以外的场上可送墓卡用于后续处理。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 效果发动合法性检查：自己场上是否存在满足条件的可对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 在选择对象前向玩家发送“请选择表侧表示的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只满足条件的怪兽作为效果对象。
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取除对象以外场上所有可送去墓地的卡（此处计算后未直接使用，效果处理时重新获取）。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc)
end
-- ①效果处理：将所取对象以外的场上全部卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local exc=nil
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then exc=tc end
	-- 获取场上除对象（若仍有效且为怪兽）以外所有能被送去墓地的卡。
	local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	-- 将这些卡全部送去墓地（效果处理）。
	Duel.SendtoGrave(dg,REASON_EFFECT)
end
-- ②效果的诱发条件：对方玩家成功特殊召唤怪兽。
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义②效果从卡组·额外卡组送墓的筛选条件：怪兽且能被送去墓地，并属于「刻魔」系列（0x1b0）。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and c:IsSetCard(0x1b0)
end
-- ②效果的发动条件与操作设定：卡组·额外卡组存在符合条件的「刻魔」怪兽，并设置送墓操作信息。
function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·额外卡组是否存在1张以上可送去墓地的「刻魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置效果处理时将1只「刻魔」怪兽送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果处理：玩家选择1只「刻魔」怪兽送去墓地。
function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在选择送墓卡片前向玩家发送“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组·额外卡组选择1张符合条件的「刻魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「刻魔」怪兽送去墓地（效果处理）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
