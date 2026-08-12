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
-- 初始化卡片效果，注册灵摆属性、创建触发效果和克隆效果，设置灵摆区域的触发效果、召唤时的效果和被破坏时的效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和使用灵摆卡效果
	aux.EnablePendulumAttribute(c)
	-- 注册一个合并的延迟事件监听器，用于监听被破坏时的事件并统一处理
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
-- 过滤函数，用于判断被破坏的怪兽是否满足条件：处于表侧表示、类型为融合/同调/超量、位置在场上、控制者为自己、破坏原因为战斗或对方效果，并且卡组中存在相同种族的灵摆怪兽
function s.cfilter(c,tp,tgchk)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)>0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
		-- 当tgchk为假时，检查卡组中是否存在满足条件的灵摆怪兽
		and (tgchk or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalRace()))
end
-- 过滤函数，用于筛选种族包含指定种族的灵摆怪兽
function s.filter(c,race)
	return c:IsType(TYPE_PENDULUM) and (c:GetOriginalRace()&race)>0
end
-- 判断是否满足灵摆效果触发条件：是否有满足cfilter条件的怪兽被破坏
function s.txcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,false)
end
-- 设置灵摆效果的目标，筛选满足条件的被破坏怪兽并计算其种族，设置操作信息为将灵摆怪兽加入额外卡组
function s.txtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.cfilter,nil,tp,true)
	local race=0
	-- 遍历被破坏的怪兽组，提取其种族并进行位运算合并
	for tc in aux.Next(g) do
		race=race|tc:GetOriginalRace()
	end
	e:SetLabel(race)
	-- 设置操作信息，表示将要从卡组加入额外卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 执行灵摆效果的操作，选择满足种族条件的灵摆怪兽并将其加入额外卡组
function s.txop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 提示玩家选择要加入额外卡组的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要加入额外卡组的卡"
	-- 选择满足种族条件的灵摆怪兽
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,race)
	if #tg>0 then
		-- 将选中的灵摆怪兽加入额外卡组
		Duel.SendtoExtraP(tg,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选4星以下的灵摆怪兽
function s.sfilter(c)
	return c:IsLevelBelow(4) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置召唤效果的目标，检查是否有灵摆区域的卡可作为目标，以及卡组中是否有满足条件的灵摆怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	-- 检查是否有灵摆区域的卡可作为目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil)
		-- 检查卡组中是否有满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的灵摆区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择灵摆区域的卡和自身作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)+e:GetHandler()
	-- 设置操作信息，表示将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息，表示将要从卡组加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行召唤效果的操作，破坏目标卡和自身，然后从卡组选择灵摆怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的目标卡
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(Card.IsRelateToChain,nil)
	-- 判断是否成功破坏了目标卡
	if #g<2 or Duel.Destroy(g,REASON_EFFECT)<2 then return end
	-- 提示玩家选择要加入手牌的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的灵摆怪兽
	local sg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #sg==0 then return end
	-- 将选中的灵摆怪兽加入手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 确认对方看到加入手牌的卡
	Duel.ConfirmCards(1-tp,sg)
end
-- 判断是否为灵摆召唤成功触发的召唤效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 判断是否为被破坏时触发的放置效果，要求破坏前位置在场上且处于表侧表示
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceupEx()
end
-- 设置放置灵摆刻度效果的目标，检查是否有灵摆区域的空位
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有灵摆区域的空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行放置灵摆刻度效果的操作，将自身移动到灵摆区域
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否与连锁相关，若相关则移动到灵摆区域
	if c:IsRelateToChain() then Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end
