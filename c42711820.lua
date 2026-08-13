--スクラップ・ウォリアー
-- 效果：
-- 「废铁同调士」＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组选1只「废品同调士」或者1张有「废品战士」的卡名记述的卡加入手卡或送去墓地。
-- ②：「废铁战士」以外的自己场上的以下怪兽发动的效果不会被无效化。
-- ●有「废品战士」的卡名记述的怪兽
-- ●原本卡名包含「战士」的同调怪兽
local s,id,o=GetID()
-- 初始化函数：为废铁战士登记关联卡名（废品战士、废品同调士）、同调素材「废铁同调士」、同调召唤手续（废铁同调士+调整以外1只以上）及苏生限制，并注册①检索/送墓效果和②效果无效抗性效果。
function s.initial_effect(c)
	-- 将废品战士(60800381)和废品同调士(63977008)加入本卡的记述卡名列表，使相关效果能识别“有「废品战士」卡名记述的卡”。
	aux.AddCodeList(c,60800381,63977008)
	-- 将废铁同调士(16449363)登记为本卡的同调素材卡名并同时加入记述卡名列表，用于满足同调召唤素材条件及相关效果判定。
	aux.AddMaterialCodeList(c,16449363)
	-- 为这张卡添加同调召唤手续：调整怪兽必须为「废铁同调士」或者持有20932152效果（可作为「同调士」调整代替的怪兽），调整以外的怪兽任意，合计至少1只。
	aux.AddSynchroProcedure(c,s.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：“这个卡名的①的效果1回合只能使用1次。①：这张卡同调召唤的场合才能发动。从卡组选1只「废品同调士」或者1张有「废品战士」的卡名记述的卡加入手卡或送去墓地。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 对应效果原文：“②：「废铁战士」以外的自己场上的以下怪兽发动的效果不会被无效化。●有「废品战士」的卡名记述的怪兽 ●原本卡名包含「战士」的同调怪兽。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.effectfilter)
	c:RegisterEffect(e2)
end
s.material_setcode=0x1017
-- 定义同调素材中调整一侧的筛选条件：素材可以是「废铁同调士」(16449363)，也可以是带有20932152效果（可代替「同调士」调整成为素材）的怪兽。
function s.tfilter(c)
	return c:IsCode(16449363) or c:IsHasEffect(20932152)
end
-- 效果①的发动条件：只有当这张卡是以同调召唤方式成功特殊召唤的场合才满足。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义从卡组选卡的筛选函数：候选卡必须是「废品同调士」或者卡名记述了「废品战士」的卡，并且该卡能够加入手卡或能够送去墓地。
function s.thfilter(c)
	-- 筛选核心条件：卡是「废品同调士」(63977008) 或卡名有「废品战士」记述，同时该卡可加入手卡或可送去墓地，任一移动方式可用即可。
	return (c:IsCode(63977008) or aux.IsCodeListed(c,60800381)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果①的发动目标阶段：检查我方卡组里是否存在至少1张满足s.thfilter筛选条件的卡，若存在则效果可发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动合法性检查）时，确认卡组中存在1张符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①处理：从卡组选取1张符合条件的卡，由玩家选择将其加入手卡或送去墓地；若选择加入手卡，还需向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示：请选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让操作玩家从自己卡组中选出1张满足s.thfilter条件的卡，用于后续处理。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 分支判断：若所选卡能加入手卡，且（不能送去墓地或玩家在“加入手卡/送去墓地”选项中选择了加入手卡），则执行加入手卡。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选择的卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将刚加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	elseif tc:IsAbleToGrave() then
		-- 将选择的卡送去墓地，处理原因为效果。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果的判定函数：判断一个发动中的怪兽效果是否属于“自己场上的「废铁战士」以外的、记述了「废品战士」卡名的怪兽或原本卡名包含「战士」的同调怪兽”。
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 从连锁信息中获取发动效果的卡的效果对象、发动玩家和发动位置，用于判定被保护的效果是否来自符合条件的己方怪兽。
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and not tc:IsCode(id) and loc==LOCATION_MZONE and te:IsActiveType(TYPE_MONSTER)
		-- 保护条件最终判定：满足（原本卡名含有“战士”且为同调怪兽）或（卡名记述了「废品战士」）的怪兽，其发动的效果不会被无效化。
		and (tc:IsOriginalSetCard(0x66) and tc:IsType(TYPE_SYNCHRO) or aux.IsCodeListed(tc,60800381))
end
