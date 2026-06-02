--心宿りし青眼竜
-- 效果：
-- 这个卡名在规则上也当作「千年」卡使用。这个卡名的①的效果1回合只能使用1次，③的效果在自己把「千年十字」发动的决斗中才能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「千年十字」加入手卡。
-- ②：这张卡的控制权不能变更。
-- ③：这张卡在墓地存在的状态，对方把8星以上或攻击力3000以上的怪兽召唤·特殊召唤的场合才能发动。那些怪兽送去墓地，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册丢弃自身检索「千年十字」的起动效果，控制权不能变更的永续效果，对方召唤·特招特定怪兽时将其送墓并自身从墓地特招的诱发效果，合并延迟事件监听器，以及用于决斗中是否发动过「千年十字」的全局监测效果
function s.initial_effect(c)
	-- 将「千年十字」(37613663)加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,37613663)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「千年十字」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的控制权不能变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，对方把8星以上或攻击力3000以上的怪兽召唤·特殊召唤的场合才能发动。那些怪兽送去墓地，这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 注册合并延迟事件处理器，用于收集和处理多只怪兽同时召唤成功时的时点
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SUMMON_SUCCESS)
	-- 注册合并延迟事件处理器，用于收集和处理多只怪兽同时特殊召唤成功时的时点
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
	if not s.global_check then
		s.global_check=true
		-- ③的效果在自己把「千年十字」发动的决斗中才能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(s.checkcon)
		ge1:SetOperation(s.checkop)
		-- 将全局监测发动的效果注册给第0位玩家（即全局环境）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监测效果的判定条件：判定是否有「千年十字」(37613663)作为魔陷卡片的发动被触发
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsCode(37613663) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 全局监测效果的处理：给发动「千年十字」的玩家注册全局已发动的标识，并注册当该发动被无效时重置清除该标识的事件处理器
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动「千年十字」的玩家是否尚未被标记已发动过该卡
	if Duel.GetFlagEffect(rp,id)==0 then
		-- 为玩家注册全局已发动的FlagEffect标识，记录其在决斗中发过「千年十字」
		Duel.RegisterFlagEffect(rp,id,0,0,0)
		-- ③的效果在自己把「千年十字」发动的决斗中才能使用1次。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_NEGATED)
		e1:SetOperation(s.rsop)
		e1:SetLabelObject(re)
		e1:SetReset(RESET_CHAIN)
		-- 为玩家注册全局持续效果，用于在所发动的「千年十字」被无效时重置已发动标识
		Duel.RegisterEffect(e1,rp)
	end
end
-- 重置操作判定：若被无效的效果与之前记录的发动效果一致，则清除该玩家发过「千年十字」的标识
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject()==re then
		-- 重置并清除玩家已发动过「千年十字」的全局FlagEffect标识
		Duel.ResetFlagEffect(tp,id)
	end
end
-- 检索效果的代价判定：判定此卡在手卡是否可以丢弃，并执行送去墓地的操作
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡丢弃并送去墓地作为效果发动的代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中的「千年十字」(37613663)且该卡能加入手牌
function s.thfilter(c)
	return c:IsCode(37613663) and c:IsAbleToHand()
end
-- 检索效果的目标判定：检测卡组中是否有能检索的目标卡，并注册检索和加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家卡组中是否存在至少1张可以加入手牌的「千年十字」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册从卡组将卡片加入手牌的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理操作：从卡组将1张「千年十字」加入手牌并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在界面上提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取卡组中符合检索过滤条件的第一张「千年十字」
	local tc=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil):GetFirst()
	if tc then
		-- 将选中的卡片从卡组加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认已检索并加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 特殊召唤效果的判定条件：判定该决斗中玩家是否曾发动过「千年十字」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动玩家是否拥有代表已发动「千年十字」的全局标识
	return Duel.GetFlagEffect(tp,id)>0
end
-- 过滤对方召唤·特殊召唤到场上、处于表侧表示、且等级在8以上或攻击力在3000以上的怪兽
function s.tdfilter(c,tp,e)
	return (c:IsAttackAbove(3000) or c:IsLevelAbove(8)) and c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的目标判定：筛选符合条件的召唤·特招成功的怪兽，并判定在这些怪兽离场后是否有可用的怪兽区空格以及自身能否特殊召唤，如果是则将目标怪兽设为影响对象并注册特招与送墓的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.tdfilter,nil,tp)
	-- 判定若目标怪兽被送去墓地后，自己是否仍有可用的怪兽区域空格
	if chk==0 then return Duel.GetMZoneCount(tp,g,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:GetCount()>0 end
	-- 将所有符合条件的对方召唤·特殊召唤的怪兽设为当前连锁的处理对象
	Duel.SetTargetCard(g)
	-- 注册将此卡特殊召唤的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 注册将目标怪兽送去墓地的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 特殊召唤效果的操作处理：将符合条件的目标怪兽送去墓地，并在成功送墓至少1只且此卡仍合法存在于墓地的情况下，将此卡在自己场上特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与该效果关联的怪兽对象组成的卡片组
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 若存在关联的怪兽对象，且成功通过效果将其送去墓地，并且有至少1只怪兽实际送达了墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 若此卡与该效果的关联依然有效，且此卡在墓地中的操作不受「王家长眠之谷」等效果的影响
		and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 以表侧表示将该卡从墓地特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
