--魔術師の弟子－ブラック・マジシャン・ガール
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡的卡名当作「黑魔术少女」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「光之黄金柜」加入手卡。
-- ③：这张卡的攻击力上升有「光之黄金柜」的卡名记述的双方墓地的怪兽数量×300。
local s,id,o=GetID()
-- 注册本卡全部效果：①特殊召唤规则效果（丢弃1手卡从手卡特殊召唤，并附加卡名改变），②召唤/特殊召唤成功时检索「光之黄金柜」，③攻击力上升效果
function s.initial_effect(c)
	-- 将「黑魔术少女」(38033121)和「光之黄金柜」(79791878)登记为本卡效果文本中记载的卡名
	aux.AddCodeList(c,38033121,79791878)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「光之黄金柜」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击力上升有「光之黄金柜」的卡名记述的双方墓地的怪兽数量×300。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则效果的发动条件：手牌特殊召唤时主怪兽区有空位，且手牌中除自身外有1张可丢弃的卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主要怪兽区域是否有空位，用于容纳从手卡特殊召唤的这张卡
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在1张不包含这张卡自身、且可以作为特殊召唤COST丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c,REASON_SPSUMMON)
end
-- 特殊召唤规则效果的目标选择：从手牌候选卡中选出1张要丢弃的手牌并暂存，选择成功则效果可发动
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足可丢弃条件（不包含这张卡自身）的手牌，作为丢弃COST的候选集合
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c,REASON_SPSUMMON)
	-- 弹出手牌选择提示，要求玩家选择1张要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理：将选中的手牌丢弃，并把这张卡特殊召唤，然后给它附加卡名当作「黑魔术少女」的永续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的那张手牌以特殊召唤手续+丢弃的理由送去墓地，即支付丢弃1张手牌的COST
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
	-- 这个方法特殊召唤的这张卡的卡名当作「黑魔术少女」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(38033121)
	e1:SetReset(RESET_EVENT+0xfe0000)
	c:RegisterEffect(e1)
end
-- 定义检索过滤条件：卡号为79791878（「光之黄金柜」）且能够加入手牌
function s.thfilter(c)
	return c:IsCode(79791878) and c:IsAbleToHand()
end
-- ②效果的发动条件与操作信息设置：卡组存在可加入手牌的「光之黄金柜」时才可发动，并登记回手牌/检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：卡组中是否存在至少1张「光之黄金柜」且能加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理包含将卡加入手牌的分类，目标位置为卡组，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组搜索1张「光之黄金柜」加入手牌，并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡组选择提示，要求玩家选择1张要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足s.thfilter（「光之黄金柜」且可加入手牌）的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「光之黄金柜」加入其持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手展示加入手牌的那张卡，以确认检索结果
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义攻击力上升效果的过滤函数：双方墓地中记载有「光之黄金柜」卡名的怪兽
function s.atkfilter(c)
	-- 判断该卡是怪兽卡，且效果文本中记载了「光之黄金柜」(79791878)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,79791878)
end
-- 计算攻击力上升数值：双方墓地中记载「光之黄金柜」的怪兽数量×300
function s.atkval(e,c)
	-- 统计双方墓地中满足s.atkfilter的怪兽数量并乘以300，作为攻击力上升值
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*300
end
