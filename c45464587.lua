--ＧＰ－アニヒレーター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方回合，以场上1只融合·同调·超量·连接怪兽为对象才能发动（自己基本分比对方少的场合，这个效果的对象可以变成2只）。那只怪兽破坏。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-暗杀者」特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册同调召唤手续并创建两个效果
function s.initial_effect(c)
	-- 记录该卡具有「黄金荣耀-暗杀者」的卡名
	aux.AddCodeList(c,60203670)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：对方回合，以场上1只融合·同调·超量·连接怪兽为对象才能发动（自己基本分比对方少的场合，这个效果的对象可以变成2只）。那只怪兽破坏。
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
	-- 效果②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-暗杀者」特殊召唤。
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
-- 效果①的发动条件：当前回合玩家为对方
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤场上正面表示的融合·同调·超量·连接怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 效果①的发动时选择对象阶段，根据LP差决定选择1~2只怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.desfilter(chkc) end
	-- 检查是否有满足条件的怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=nil
	-- 判断自己基本分是否比对方少
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		-- 提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择1~2只满足条件的怪兽作为对象
		g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	else
		-- 提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择1只满足条件的怪兽作为对象
		g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	end
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果①的发动处理，破坏选定的怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标怪兽，并过滤出与效果相关的怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsType,nil,TYPE_MONSTER)
	if tg:GetCount()>0 then
		-- 将满足条件的怪兽破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 效果②的发动条件：效果①已发动
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 效果②的发动时处理阶段，设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将此卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设置操作信息为从卡组或墓地特殊召唤1只「黄金荣耀-暗杀者」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 过滤可特殊召唤的「黄金荣耀-暗杀者」
function s.spfilter(c,e,tp)
	return c:IsCode(60203670) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动处理，将此卡送回额外卡组并特殊召唤「黄金荣耀-暗杀者」
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster()
		-- 将此卡送回额外卡组且确认送回成功，且此卡在额外卡组
		and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		-- 确认己方场上存在空位可特殊召唤怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只满足条件的「黄金荣耀-暗杀者」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选定的「黄金荣耀-暗杀者」特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
