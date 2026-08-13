--フォアグラシャ・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡回到持有者卡组。
-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只5·6星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 为这张卡添加苏生限制（对应「食谱」卡降临的仪式召唤条件）；创建并注册①效果：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动，那些卡回到持有者卡组（1回合1次）；创建并注册②效果：场上怪兽成为攻击·效果的对象时才能发动，解放自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽，从手卡·卡组把1只5·6星的「新式魔厨」仪式怪兽特殊召唤（1回合1次）；再克隆②效果用于应对“成为攻击对象”的触发。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"墓地的卡回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只5·6星的「新式魔厨」仪式怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	-- 将②效果的克隆e3的发动条件设为恒真，表示只要本卡在怪兽区且场上怪兽被选为攻击对象即可发动（攻击对象事件本身已限定触发，无需额外条件）。
	e3:SetCondition(aux.TRUE)
	c:RegisterEffect(e3)
end
-- ①效果的发动时处理：选择自己或对方墓地中合计1~3张能被送回卡组的卡作为对象，并设置“回卡组”的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	-- 发动合法性检查：确认墓地中至少存在1张可以被送回卡组的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 弹出“请选择要返回卡组的卡”的选择提示，供玩家从墓地中选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从双方墓地选择1~3张可回卡组的卡，并将其设为该连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置操作信息：本次效果将把已选中的g张卡（数量为g:GetCount()）返回持有者卡组，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ①效果处理：取得当前连锁中仍与效果关联的对象卡，若存在则全部返回持有者卡组并洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡组（即发动时选择的墓地卡片，若中途离场则自动解除关联）。
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将这些对象卡送去持有者卡组，SEQ_DECKSHUFFLE表示弹回卡组后洗牌，原因记为效果。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：成为对象（eg）的卡中存在位于主要怪兽区的怪兽，即满足“场上的怪兽成为对象”。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0
end
-- 第一只解放物的筛选：自己场上的「新式魔厨」怪兽且可被效果解放；同时场上还存在另一只满足relfilter2的攻击表示怪兽可作为第二只解放物。
function s.relfilter1(c,tp)
	return c:IsSetCard(0x196) and c:IsReleasableByEffect()
		-- 进一步检查：除当前候选卡c外，双方场上还存在至少1只满足relfilter2的攻击表示怪兽，确保第二只解放物可选。
		and Duel.IsExistingMatchingCard(s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
end
-- 第二只解放物的筛选：可被效果解放且为攻击表示的怪兽；同时解放c和ec后自己场上仍有空位可进行特殊召唤。
function s.relfilter2(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 确认解放候选第二只c和第一只ec后，自己场上仍有可用的主要怪兽区空格，避免解放后无格子特召。
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- 特召目标的筛选：手卡·卡组中的5星或6星「新式魔厨」仪式怪兽（类型含怪兽+仪式），且能被效果特殊召唤（已满足苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(5,6) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动前目标检查：必须同时存在可解放的自己场上「新式魔厨」怪兽（连带第二只攻击表示怪兽）以及可特召的仪式怪兽，并设置特召操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否至少存在1只满足relfilter1的自己场上的「新式魔厨」怪兽（即存在可解放的一组解放物）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查是否至少存在1只满足spfilter的、在手卡/卡组的5~6星「新式魔厨」仪式怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将特殊召唤1只怪兽，来源为手卡/卡组，供后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：选择并解放自己场上1只「新式魔厨」怪兽和双方场上1只攻击表示怪兽，若解放成功则从手卡/卡组特召1只5~6星「新式魔厨」仪式怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要解放的第一只卡（自己场上的「新式魔厨」怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择第一只解放对象：自己场上满足relfilter1的「新式魔厨」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.relfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g:GetFirst()
	if not tc1 then return end
	-- 提示玩家选择要解放的第二只卡（攻击表示怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择第二只解放对象：双方场上满足relfilter2的攻击表示怪兽（不能选择第一只tc1），并取第一张。
	local tc2=Duel.SelectMatchingCard(tp,s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc1,tp,tc1):GetFirst()
	g:AddCard(tc2)
	-- 将选择的两只怪兽解放；若实际解放数量不等于2，说明出现意外（如被无效），则中止后续特召处理。
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡/卡组选择1只满足spfilter的仪式怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的仪式怪兽以表侧表示特殊召唤到自己的主要怪兽区（nocheck为true表示不检查召唤条件，苏生限制仍由spfilter保证）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
