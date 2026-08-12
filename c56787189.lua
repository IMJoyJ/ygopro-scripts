--開かれし大地
-- 效果：
-- ①：对方把仪式·融合·同调·超量·连接怪兽特殊召唤的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●把1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
-- ●把1只「阿不思的落胤」或者有那个卡名记述的怪兽从手卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动效果（e1）以及对方特殊召唤特定怪兽时选择效果发动的诱发效果（e2）
function s.initial_effect(c)
	-- 将「阿不思的落胤」的卡片密码（68468459）注册到该卡的关联卡片列表中，以便其他卡片进行相关检索检测
	aux.AddCodeList(c,68468459)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方把仪式·融合·同调·超量·连接怪兽特殊召唤的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"选择效果发动"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
-- 过滤条件：对方场上表侧表示的仪式、融合、同调、超量或连接怪兽
function s.cfilter(c,sp)
	return c:IsFaceup() and c:IsSummonPlayer(sp)
		and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 发动条件：对方特殊召唤了仪式、融合、同调、超量或连接怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 过滤条件：卡组中可以加入手卡的「阿不思的落胤」或记述了该卡名的怪兽
function s.thfilter(c)
	-- 判断卡片是否为「阿不思的落胤」或记述了该卡名的怪兽
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToHand()
end
-- 过滤条件：手卡中可以特殊召唤的「阿不思的落胤」或记述了该卡名的怪兽
function s.spfilter(c,e,tp)
	-- 判断卡片是否为「阿不思的落胤」或记述了该卡名的怪兽
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与处理分支判定，根据本回合已使用的效果标记，让玩家选择并决定本次发动的效果分支（检索或特召），并注册对应的操作信息和回合内已使用标记
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家本回合已发动的效果分支标记（Label）
	local l=Duel.GetFlagEffectLabel(tp,id)
	-- 判断本回合是否未选择过第1个效果（检索），且卡组中是否存在可检索的卡
	local b1=(not l or l&1==0) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 判断本回合是否未选择过第2个效果（特召），且己方场上有可用的怪兽区域
	local b2=(not l or l&2==0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在可特殊召唤的卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 提示玩家选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if b1 and b2 then
		-- 当两个效果都可选时，让玩家在“卡组检索”和“手卡特召”中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"卡组检索/特殊召唤"
	elseif b1 then
		-- 当只有第1个效果可选时，强制选择“卡组检索”
		op=Duel.SelectOption(tp,aux.Stringid(id,1))  --"卡组检索"
	else
		-- 当只有第2个效果可选时，强制选择“手卡特召”
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"特殊召唤"
	end
	if op==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e:SetOperation(s.thop)
		-- 如果已存在标记，则将标记的第1位设为1（表示本回合已使用过第1个效果）
		if l then Duel.SetFlagEffectLabel(tp,id,l|1)
		-- 如果不存在标记，则注册一个回合结束时重置的标记，并设置Label为1（表示本回合已使用过第1个效果）
		else Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,1) end
		-- 设置连锁操作信息：从卡组将1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		-- 如果已存在标记，则将标记的第2位设为1（表示本回合已使用过第2个效果）
		if l then Duel.SetFlagEffectLabel(tp,id,l|2)
		-- 如果不存在标记，则注册一个回合结束时重置的标记，并设置Label为2（表示本回合已使用过第2个效果）
		else Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,2) end
		-- 设置连锁操作信息：特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 第1个效果（检索）的处理：从卡组选择1张符合条件的卡加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡因效果加入手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家确认加入手卡的卡片
	Duel.ConfirmCards(1-tp,g)
end
-- 第2个效果（特召）的处理：若场上有空位，则从手卡选择1只符合条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
