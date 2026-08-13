--プランキッズの大作戦
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。用自己场上的「调皮宝贝」怪兽为素材把1只「调皮宝贝」连接怪兽连接召唤。
-- ②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。选自己墓地的「调皮宝贝」卡任意数量回到卡组，那只攻击怪兽的攻击力直到回合结束时下降回去数量×100。
function c15447747.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段才能发动。用自己场上的「调皮宝贝」怪兽为素材把1只「调皮宝贝」连接怪兽连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,15447747)
	e2:SetCondition(c15447747.lkcon)
	e2:SetTarget(c15447747.lktg)
	e2:SetOperation(c15447747.lkop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。选自己墓地的「调皮宝贝」卡任意数量回到卡组，那只攻击怪兽的攻击力直到回合结束时下降回去数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,15447748)
	e3:SetCondition(c15447747.atkcon)
	-- 设置②效果的发动代价：将墓地中的这张卡除外才能发动（对应原文‘把墓地的这张卡除外才能发动’）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c15447747.atktg)
	e3:SetOperation(c15447747.atkop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件函数：判定当前是否处于主要阶段1或主要阶段2，限定①效果只能在自己·对方的主要阶段发动。
function c15447747.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2，即判断是否满足①效果的发动阶段条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义连接素材过滤函数：筛选自己场上表侧表示且拥有「调皮宝贝」字段的怪兽，作为连接召唤的素材候选。
function c15447747.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x120)
end
-- 定义额外怪兽过滤函数：筛选额外卡组中拥有「调皮宝贝」字段且能够以当前素材组进行连接召唤的连接怪兽。
function c15447747.lkfilter(c,mg)
	return c:IsSetCard(0x120) and c:IsLinkSummonable(mg)
end
-- ①效果的发动目标函数：在发动时检查自己场上是否有「调皮宝贝」怪兽素材、额外卡组是否有可连接召唤的「调皮宝贝」连接怪兽；满足则设置特殊召唤的操作信息。
function c15447747.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上表侧表示的「调皮宝贝」怪兽集合，作为连接召唤的可用素材组。
		local mg=Duel.GetMatchingGroup(c15447747.matfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组是否存在至少1只能用上述素材组进行连接召唤的「调皮宝贝」连接怪兽，以此作为①效果的发动条件。
		return Duel.IsExistingMatchingCard(c15447747.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	-- 设置操作信息：本次效果将进行1只额外卡组怪兽的特殊召唤，供连锁检测与相关限制效果判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理函数：实际执行连接召唤——从自己场上选择「调皮宝贝」怪兽为素材，从额外卡组选择1只符合条件的「调皮宝贝」连接怪兽，进行连接召唤。
function c15447747.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时重新获取自己场上表侧表示的「调皮宝贝」怪兽集合，保证使用当前最新的素材状态。
	local mg=Duel.GetMatchingGroup(c15447747.matfilter,tp,LOCATION_MZONE,0,nil)
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只符合条件且能用当前素材组进行连接召唤的「调皮宝贝」连接怪兽。
	local tg=Duel.SelectMatchingCard(tp,c15447747.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
	local tc=tg:GetFirst()
	if tc then
		-- 以mg为素材，让玩家tp将选择的连接怪兽tc进行连接召唤。
		Duel.LinkSummon(tp,tc,mg)
	end
end
-- ②效果的发动条件函数：检测对方怪兽是否进行了攻击宣言，通过攻击怪兽的控制者是否为对方来判断。
function c15447747.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回攻击宣言怪兽的控制者是否为对方（1-tp），满足②效果“对方怪兽的攻击宣言时”的发动条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 定义回卡组过滤函数：筛选自己墓地中拥有「调皮宝贝」字段且能够返回卡组的卡。
function c15447747.tdfilter(c)
	return c:IsSetCard(0x120) and c:IsAbleToDeck()
end
-- ②效果的发动目标函数：检查自己墓地是否存在可返回卡组的「调皮宝贝」卡（排除作为cost已除外的本卡），并设置回卡组的操作信息。
function c15447747.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查：自己墓地是否存在至少1张除本卡以外满足条件的「调皮宝贝」卡可以返回卡组，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15447747.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息：本次效果将处理自己墓地中的「调皮宝贝」卡返回卡组，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理函数：选择自己墓地任意数量「调皮宝贝」卡返回卡组并洗牌，然后根据返回数量让攻击怪兽攻击力下降（数量×100）直到回合结束。
function c15447747.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前发动攻击的对方怪兽，作为攻击力下降效果的目标。
	local tc=Duel.GetAttacker()
	-- 显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1~99张满足条件的「调皮宝贝」卡（即任意数量），作为返回卡组的对象。
	local g=Duel.SelectMatchingCard(tp,c15447747.tdfilter,tp,LOCATION_GRAVE,0,1,99,nil)
	local ct=#g
	if ct>0 then
		-- 将选中的卡高亮显示，作为被选中对象的提示，并记录这些卡被选择。
		Duel.HintSelection(g)
	end
	-- 将选中的卡返回持有者卡组并洗牌；若实际返回数量为0，则直接结束后续处理。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	if tc:IsFaceup() and tc:IsRelateToBattle() and ct>0 then
		-- 那只攻击怪兽的攻击力直到回合结束时下降回去数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*-100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
