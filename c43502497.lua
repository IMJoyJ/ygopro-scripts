--ペンデュラム・ウィッチ
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：这张卡在灵摆区域存在的状态，自己场上的表侧表示的融合·同调·超量怪兽被战斗或者对方的效果破坏的场合才能发动。原本种族和那之内的1只相同的1只灵摆怪兽从卡组表侧加入额外卡组。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·灵摆召唤的场合，以自己的灵摆区域1张卡为对象才能发动。那张卡和这张卡破坏，从卡组把1只4星以下的灵摆怪兽加入手卡。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 注册灵摆魔女全部效果：赋予灵摆召唤属性；注册①灵摆效果（融合·同调·超量怪兽被战斗或对方效果破坏时，从卡组将同原种族的灵摆怪兽表侧加入额外卡组）；注册①怪兽效果（召唤/灵摆召唤时，破坏灵摆区1张卡和自身，并从卡组将1只4星以下灵摆怪兽加入手卡）；注册②怪兽效果（怪兽区域的这张卡被破坏时，放置到灵摆区域）。
function s.initial_effect(c)
	-- 为该卡添加灵摆怪兽的基本属性（灵摆召唤、灵摆卡发动等基础能力）。
	aux.EnablePendulumAttribute(c)
	-- 为这张卡注册一个合并的延迟事件监听，统一监听场上怪兽被破坏的事件，返回自定义事件码custom_code，用于作为①灵摆效果的触发代码。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_DESTROYED)
	-- ①：这张卡在灵摆区域存在的状态，自己场上的表侧表示的融合·同调·超量怪兽被战斗或者对方的效果破坏的场合才能发动。原本种族和那之内的1只相同的1只灵摆怪兽从卡组表侧加入额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.txcon)
	e1:SetTarget(s.txtg)
	e1:SetOperation(s.txop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·灵摆召唤的场合，以自己的灵摆区域1张卡为对象才能发动。那张卡和这张卡破坏，从卡组把1只4星以下的灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.thcon)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"放置灵摆刻度"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.pzcon)
	e4:SetTarget(s.pztg)
	e4:SetOperation(s.pzop)
	c:RegisterEffect(e4)
end
-- 被破坏怪兽的过滤条件：破坏前表侧表示、场上的原种类包含融合/同调/超量、破坏前位于我方怪兽区且控制者为我方、破坏原因为战斗或对方效果（若非目标确认模式，还需卡组存在可检索的同种族灵摆怪兽）。
function s.cfilter(c,tp,tgchk)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)>0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
		-- 若非目标确认模式，则额外检查卡组中是否存在与被破坏怪兽原种族相同的灵摆怪兽，以保证效果处理时有可检索目标。
		and (tgchk or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalRace()))
end
-- 检索目标的过滤条件：是灵摆怪兽，且其原种族与指定race有重叠（按位与非0）。
function s.filter(c,race)
	return c:IsType(TYPE_PENDULUM) and (c:GetOriginalRace()&race)>0
end
-- ①灵摆效果的发动条件：本次被破坏的怪兽集合中存在至少1只满足cfilter的怪兽（不在此步检查卡组是否有目标）。
function s.txcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,false)
end
-- ①灵摆效果发动时的目标处理：若效果可以发动，取出所有满足条件的被破坏怪兽，把它们的原种族按位或合并后记录到效果标签，并设置操作信息为从卡组将1张卡加入额外卡组。
function s.txtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.cfilter,nil,tp,true)
	local race=0
	-- 遍历满足条件的被破坏怪兽，累加它们的原种族（按位或），使后续检索能够匹配其中任意一种种族。
	for tc in aux.Next(g) do
		race=race|tc:GetOriginalRace()
	end
	e:SetLabel(race)
	-- 设置操作信息，声明本次效果将从卡组把1张卡表侧加入额外卡组，用于系统检测（如星尘龙等）以及连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- ①灵摆效果处理：读取记录的原种族，让玩家从卡组选择1只相同原种族的灵摆怪兽，表侧加入额外卡组。
function s.txop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 给玩家显示选择提示：请选择要加入额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要加入额外卡组的卡"
	-- 从卡组筛选出满足filter条件的卡（灵摆怪兽且原种族匹配），让玩家选择1张。
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,race)
	if #tg>0 then
		-- 将选择的卡以效果原因表侧送去持有者的额外卡组。
		Duel.SendtoExtraP(tg,nil,REASON_EFFECT)
	end
end
-- 检索手牌目标的过滤条件：4星以下、灵摆怪兽、并且可以加入手卡。
function s.sfilter(c)
	return c:IsLevelBelow(4) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- ①怪兽效果的发动条件与对象指定：若为对象合法性检查，则必须是我方灵摆区的卡；若为发动条件检查，则需要我方灵摆区存在至少1张可选对象，且卡组存在至少1只满足sfilter的灵摆怪兽。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	-- 检查我方灵摆区是否存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil)
		-- 检查卡组中是否存在至少1只满足sfilter的4星以下灵摆怪兽可加入手卡。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从我方灵摆区选择1张卡作为对象，并与效果处理中的这张卡自身一起构成要破坏的卡组g；选择的对象会与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)+e:GetHandler()
	-- 设置操作信息：本连锁将破坏g中的2张卡（自身和对象），供系统判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息：本连锁将把卡组中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①怪兽效果处理：从连锁中获取自身和对象，过滤出仍与连锁相关的卡；如果数量不足2或破坏没有成功2张，则终止；否则检索1只4星以下灵摆怪兽加入手卡并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的灵摆区对象卡。
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToChain,nil)
	-- 若自身和对象中仍有联系的数量不足2，或者实际破坏数量少于2，说明处理不完整，直接结束不再检索。
	if #g<2 or Duel.Destroy(g,REASON_EFFECT)<2 then return end
	-- 给玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足sfilter的灵摆怪兽（4星以下可加入手卡）。
	local sg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #sg==0 then return end
	-- 将选择的卡以效果原因加入持有者的手卡。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 向对方玩家展示加入手卡的灵摆怪兽，完成确认。
	Duel.ConfirmCards(1-tp,sg)
end
-- e3的额外发动条件：仅当这次特殊召唤是灵摆召唤时才允许发动，用来把“召唤·灵摆召唤”限制限定为灵摆召唤。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- ②效果的发动条件：这张卡被破坏前在主要怪兽区，且破坏前是表侧表示。
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceupEx()
end
-- ②效果的发动时点目标处理：只检查我方灵摆区是否有空位可放置，不取对象。
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方灵摆区左、右两个区域是否存在至少一个可用空格。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- ②效果处理：如果这张卡仍与连锁相关，则将其移动到我方灵摆区并表侧放置。
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与当前效果连锁有关联（未被除外、回卡组等导致联系丢失），若是则移动到我方灵摆区表侧表示。
	if c:IsRelateToChain() then Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end
