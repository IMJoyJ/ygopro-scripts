--ＧＰ－アニヒレーター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方回合，以场上1只融合·同调·超量·连接怪兽为对象才能发动（自己基本分比对方少的场合，这个效果的对象可以变成2只）。那只怪兽破坏。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-暗杀者」特殊召唤。
local s,id,o=GetID()
-- 初始化该卡的效果，包括登记参考卡名、设定同调召唤手续，以及注册①的对方回破坏效果和②的结束阶段回额外并特召效果。
function s.initial_effect(c)
	-- 将卡号60203670（黄金荣耀-暗杀者）登记为这张卡效果文本中提到的卡名，供规则处理时识别。
	aux.AddCodeList(c,60203670)
	-- 为这张卡添加同调召唤手续：需要调整怪兽＋调整以外的怪兽1只以上，对应“调整＋调整以外的怪兽1只以上”。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方回合，以场上1只融合·同调·超量·连接怪兽为对象才能发动（自己基本分比对方少的场合，这个效果的对象可以变成2只）。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-暗杀者」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：仅限对方回合（当前回合玩家不是这张卡的控制者）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为tp的对方（1-tp），即是否为对方回合。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义①效果可选对象的筛选条件：表侧表示且为融合/同调/超量/连接怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 定义①效果的发动目标选择逻辑：必须选择场上1只符合条件的怪兽；若己方LP低于对方，则可选1~2只；同时为②的发动登记标志。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.desfilter(chkc) end
	-- 效果发动合法性检查：确认场上至少存在1只符合条件的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=nil
	-- 判断己方基本分是否少于对方，以决定可选择对象的数量是1只还是1~2只。
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		-- 向己方玩家显示“请选择要破坏的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 当己方LP少于对方时，从双方怪兽区选择1~2只符合条件的怪兽作为效果对象。
		g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	else
		-- 向己方玩家显示“请选择要破坏的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 当己方LP不低于对方时，从双方怪兽区选择1只符合条件的怪兽作为效果对象。
		g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	end
	-- 将破坏效果的操作信息设置为选中的对象，用于后续效果处理和时点/无效等的判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 定义①效果处理：取出仍与效果关联且为怪兽的对象并破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁对象，筛选出仍与该效果相关且为怪兽的卡，作为破坏对象。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsType,nil,TYPE_MONSTER)
	if tg:GetCount()>0 then
		-- 将筛选出的对象以效果破坏送入墓地。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 定义②效果的发动条件：本回合已发动过①效果（存在对应flag标记）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 定义②效果发动时的目标设定：将这张卡回额外卡组，并预定从卡组/墓地特殊召唤1只「黄金荣耀-暗杀者」。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定将这张卡送回额外卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设定从卡组·墓地特殊召唤1只怪兽的操作信息（数量为1，检索范围包括卡组和墓地）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 定义特殊召唤对象的筛选条件：卡号必须是60203670（黄金荣耀-暗杀者），且处于可被效果特殊召唤的状态。
function s.spfilter(c,e,tp)
	return c:IsCode(60203670) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果处理：这张卡成功返回额外卡组且己方有可用怪兽区时，从自身卡组·墓地选1只「黄金荣耀-暗杀者」特殊召唤。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster()
		-- 将这张卡送回卡组顶并确认它确实返回了额外卡组，确保后续特殊召唤合法。
		and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		-- 确认己方有可用的主要怪兽区空格，用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向己方玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组·墓地选择1只符合条件的「黄金荣耀-暗杀者」（使用王家长眠之谷过滤后）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的「黄金荣耀-暗杀者」以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
