--雲魔物－ストーム・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地1只名字带有「云魔物」的怪兽从游戏中除外特殊召唤。这张卡不会被战斗破坏。这张卡表侧守备示在场上存在的场合，这张卡破坏。1回合只有1次，可以给场上1只怪兽放置1个雾指示物。
function c13474291.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备表示在场上存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c13474291.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。把自己墓地1只名字带有「云魔物」的怪兽从游戏中除外特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c13474291.spcon)
	e3:SetTarget(c13474291.sptg)
	e3:SetOperation(c13474291.spop)
	c:RegisterEffect(e3)
	-- 1回合只有1次，可以给场上1只怪兽放置1个雾指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13474291,0))  --"放置指示物"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c13474291.cttg)
	e4:SetOperation(c13474291.ctop)
	c:RegisterEffect(e4)
end
c13474291.mentioned_counter={
	[0x1019]=true,
}
-- 自我破坏的触发条件：这张卡在场上表侧守备表示存在时满足条件。
function c13474291.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 特殊召唤代价的过滤函数：筛选名字带有「云魔物」（0x18系列）、且可以作为代价除外的怪兽卡。
function c13474291.cfilter(c)
	return c:IsSetCard(0x18) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤的发动条件判定：自己的怪兽区有空位，且自己墓地存在1只以上可作为代价除外的「云魔物」怪兽。
function c13474291.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己的主要怪兽区有可用空格（没有空位则不能特殊召唤）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只名字带有「云魔物」、可以作为代价除外的怪兽。
		and Duel.IsExistingMatchingCard(c13474291.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤手续的选择处理：从自己墓地选择1只要除外的「云魔物」怪兽并记录下来；取消选择则不能特殊召唤。
function c13474291.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索自己墓地中所有满足条件的「云魔物」怪兽，作为可选择的除外对象。
	local g=Duel.GetMatchingGroup(c13474291.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送选卡提示「请选择要除外的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前选好的怪兽，将其表侧表示从游戏中除外，以此完成这张卡的特殊召唤。
function c13474291.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「云魔物」怪兽以表侧表示从游戏中除外（作为特殊召唤的手续）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 放置雾指示物效果的对象选择：确认场上存在可以放置雾指示物的怪兽，并让玩家选择其中1只作为对象。
function c13474291.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1019,1) end
	-- 效果发动条件的检查：双方怪兽区存在至少1只可以放置1个雾指示物、并能成为效果对象的怪兽时才能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1019,1) end
	-- 向玩家发送选卡提示「请选择表侧表示的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只可以放置雾指示物的怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1019,1)
end
-- 效果处理：取得对象怪兽，若它仍为表侧表示且仍是本效果的对象，则给它放置1个雾指示物。
function c13474291.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,1)
	end
end
