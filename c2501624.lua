--魔術師の弟子－ブラック・マジシャン・ガール
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡的卡名当作「黑魔术少女」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「光之黄金柜」加入手卡。
-- ③：这张卡的攻击力上升有「光之黄金柜」的卡名记述的双方墓地的怪兽数量×300。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤、检索和攻击力提升效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「黑魔术少女」和「光之黄金柜」的卡名
	aux.AddCodeList(c,38033121,79791878)
	-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡的卡名当作「黑魔术少女」使用。
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
-- 判断特殊召唤条件是否满足：场上是否有空位且手牌中是否有可丢弃的卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c,REASON_SPSUMMON)
end
-- 设置特殊召唤的处理目标：选择要丢弃的手牌
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中所有可丢弃的卡
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c,REASON_SPSUMMON)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的处理：将选中的卡送去墓地并变更此卡的卡号为「黑魔术少女」
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以特殊召唤+丢弃的原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
	-- 将此卡的卡号更改为「黑魔术少女」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(38033121)
	e1:SetReset(RESET_EVENT+0xfe0000)
	c:RegisterEffect(e1)
end
-- 检索效果的过滤函数：判断卡是否为「光之黄金柜」且可加入手牌
function s.thfilter(c)
	return c:IsCode(79791878) and c:IsAbleToHand()
end
-- 设置检索效果的目标：确认卡组中是否存在「光之黄金柜」
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「光之黄金柜」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息：准备将1张「光之黄金柜」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果：从卡组选择1张「光之黄金柜」加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「光之黄金柜」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力提升效果的过滤函数：判断墓地中的卡是否为怪兽且记载着「光之黄金柜」
function s.atkfilter(c)
	-- 判断墓地中的卡是否为怪兽且记载着「光之黄金柜」
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,79791878)
end
-- 计算攻击力提升值：双方墓地怪兽数量×300
function s.atkval(e,c)
	-- 获取双方墓地中记载着「光之黄金柜」的怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*300
end
