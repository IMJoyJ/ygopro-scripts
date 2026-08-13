--ベアルクティ・クィントチャージ
-- 效果：
-- ①：1回合1次，可以支付700基本分，从以下效果选择1个发动。
-- ●从自己墓地选1只「北极天熊」怪兽加入手卡。
-- ●自己场上2只「北极天熊」怪兽解放，把持有和那个等级差相同等级的1只「北极天熊」怪兽从额外卡组无视召唤条件特殊召唤。
-- ②：自己的「北极天熊」同调怪兽被对方的攻击破坏时才能发动。对方直到自身的手卡·场上·墓地的卡合计变成7张为止必须回到持有者卡组。
function c15758127.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以支付700基本分，从以下效果选择1个发动。●从自己墓地选1只「北极天熊」怪兽加入手卡。●自己场上2只「北极天熊」怪兽解放，把持有和那个等级差相同等级的1只「北极天熊」怪兽从额外卡组无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c15758127.cost)
	e2:SetTarget(c15758127.target)
	e2:SetOperation(c15758127.activate)
	c:RegisterEffect(e2)
	-- ②：自己的「北极天熊」同调怪兽被对方的攻击破坏时才能发动。对方直到自身的手卡·场上·墓地的卡合计变成7张为止必须回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15758127,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c15758127.tdcon)
	e3:SetTarget(c15758127.tdtg)
	e3:SetOperation(c15758127.tdop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价函数：检查并支付700基本分后才能发动。
function c15758127.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：判断玩家能否支付700基本分。
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	-- 实际支付700基本分作为发动代价。
	Duel.PayLPCost(tp,700)
end
-- 墓地回收筛选：选取卡名为「北极天熊」的怪兽且该卡能够加入手卡。
function c15758127.thfilter(c)
	return c:IsSetCard(0x163) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 解放候选筛选：选取自己场上表侧表示或由自己控制的、等级1以上的「北极天熊」怪兽作为可解放对象。
function c15758127.rfilter(c,tp)
	return (c:IsFaceup() or c:IsControler(tp)) and c:IsLevelAbove(1) and c:IsSetCard(0x163)
end
-- 判断在解放候选组g中，除当前卡c外是否存在另一只「北极天熊」怪兽，使两只怪兽的等级差等于目标等级lv。
function c15758127.mnfilter(c,g,lv)
	return g:IsExists(c15758127.mnfilter2,1,c,c,lv)
end
-- 判定两只「北极天熊」怪兽的等级差是否等于lv。
function c15758127.mnfilter2(c,mc,lv)
	return c:GetLevel()-mc:GetLevel()==lv
end
-- 额外卡组「北极天熊」怪兽特殊召唤通用筛选：需为「北极天熊」、可被特殊召唤，且解放候选离场后能腾出额外怪兽区域空位。
function c15758127.spfilter(c,e,tp,g)
	-- 特殊召唤候选须满足：是「北极天熊」、满足特殊召唤条件（nocheck=true），且解放候选后额外区有空位。
	return c:IsSetCard(0x163) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
-- 额外候选还需满足：在解放组g中存在两只「北极天熊」怪兽，其等级差等于该额外怪兽的等级。
function c15758127.spfilter1(c,e,tp,g)
	return c15758127.spfilter(c,e,tp,g) and g:IsExists(c15758127.mnfilter,1,nil,g,c:GetLevel())
end
-- 按指定等级lv筛选可特殊召唤的「北极天熊」额外怪兽。
function c15758127.spfilter2(c,e,tp,lv)
	return c15758127.spfilter(c,e,tp,nil) and c:IsLevel(lv)
end
-- 选择解放组时判断：候选组正好2只，且额外卡组存在一只可由这2只等级差特殊召唤的「北极天熊」怪兽。
function c15758127.fselect(g,e,tp)
	-- 要求解放组数量为2，并且存在对应等级差的额外「北极天熊」怪兽可以特殊召唤。
	return g:GetCount()==2 and Duel.IsExistingMatchingCard(c15758127.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- ①效果的目标处理：检测两个分支是否可行，由玩家选择发动“回收墓地”或“解放特召”，记录分支并设置对应的效果分类与操作信息。
function c15758127.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在1只以上满足回收条件的「北极天熊」怪兽，用于决定“加入手卡”分支是否可用。
	local b1=Duel.IsExistingMatchingCard(c15758127.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	-- 取得自己场上可因效果解放的怪兽中，可作为「北极天熊」解放候选的怪兽集合。
	local g=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c15758127.rfilter,nil,tp)
	local b2=g:CheckSubGroup(c15758127.fselect,2,2,e,tp)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 仅回收分支可行时，显示“加入手卡”选项，选择结果s=0。
		s=Duel.SelectOption(tp,aux.Stringid(15758127,0))  --"加入手卡"
	elseif not b1 and b2 then
		-- 仅特殊召唤分支可行时，显示“特殊召唤”选项，选择结果s=1（选项索引0加1）。
		s=Duel.SelectOption(tp,aux.Stringid(15758127,1))+1  --"特殊召唤"
	elseif b1 and b2 then
		-- 两个分支都可行时，显示“加入手卡/特殊召唤”两个选项，由玩家选择后s为0或1。
		s=Duel.SelectOption(tp,aux.Stringid(15758127,0),aux.Stringid(15758127,1))  --"加入手卡/特殊召唤"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 选择回收分支时，设置效果类别为回手牌，并记录操作信息：从墓地加入1张卡到手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 选择特召分支时，设置效果类别为特殊召唤，并记录操作信息：从额外卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- ①效果的处理：按发动时选择的分支执行，回收墓地「北极天熊」怪兽，或解放2只「北极天熊」怪兽后特殊召唤对应等级的额外怪兽。
function c15758127.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 提示操作者选择要加入手卡的卡（显示“请选择要加入手牌的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己墓地选择1只满足回收条件的「北极天熊」怪兽，并通过王家长眠之谷的过滤。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15758127.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的墓地怪兽加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片，确认回收内容。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:GetLabel()==1 then
		-- 效果处理时重新取得可解放的「北极天熊」怪兽集合。
		local g=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c15758127.rfilter,nil,tp)
		-- 提示操作者选择要解放的怪兽（显示“请选择要解放的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local rg=g:SelectSubGroup(tp,c15758127.fselect,false,2,2,e,tp)
		if rg and rg:GetCount()==2 then
			local c1=rg:GetFirst()
			local c2=rg:GetNext()
			local lv=c1:GetLevel()-c2:GetLevel()
			if lv<0 then lv=-lv end
			-- 解放所选的2只「北极天熊」怪兽，只有实际解放2只时才继续处理后续特殊召唤。
			if Duel.Release(rg,REASON_EFFECT)==2 then
				-- 提示操作者选择要特殊召唤的额外卡组怪兽（显示“请选择要特殊召唤的卡”）。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从额外卡组选择1只等级等于解放怪兽等级差的「北极天熊」怪兽，且满足特殊召唤条件。
				local sg=Duel.SelectMatchingCard(tp,c15758127.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
				if sg:GetCount()>0 then
					-- 将选中的额外「北极天熊」怪兽无视召唤条件（但检查苏生限制）表侧攻击表示特殊召唤到自己场上。
					Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 判定被战斗破坏的卡是否为之前表侧表示、由自己控制的「北极天熊」同调怪兽。
function c15758127.cfilter(c,tp)
	return c:IsPreviousSetCard(0x163) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0 and c:GetPreviousControler()==tp
end
-- ②效果的发动条件：被破坏的怪兽中存在己方「北极天熊」同调怪兽，且攻击者为对方控制的怪兽。
function c15758127.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件成立需同时满足：破坏群中有己方表侧「北极天熊」同调怪兽，且攻击怪兽属于对方。
	return eg:IsExists(c15758127.cfilter,1,nil,tp) and Duel.GetAttacker():IsControler(1-tp)
end
-- ②效果的目标处理：确认对方手卡·场上·墓地合计超过7张，并设置将超出部分返回卡组的操作信息。
function c15758127.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手卡·场上·墓地的全部卡片作为计数对象。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if chk==0 then return #g>7 end
	-- 设置操作信息：对方需要将（当前卡数-7）张卡返回卡组，涉及区域为对方手卡·场上·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,#g-7,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ②效果的处理：由对方选择手卡·场上·墓地的卡返回持有者卡组，直到总数变为7张。
function c15758127.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算对方当前手卡·场上·墓地的卡总数。
	local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 获取对方可返回卡组的卡片（应用王家长眠之谷过滤）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if ct<=7 or #g==0 then return end
	local tct=math.min(ct-7,#g)
	-- 提示对方玩家选择要返回卡组的卡（显示“请选择要返回卡组的卡”）。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(1-tp,tct,tct,nil)
	-- 将选中的卡返回持有者卡组并洗切，完成对方卡片强制返回卡组的处理。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_RULE)
end
