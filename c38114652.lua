--封神の剣鬼 ミクマリ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1只幻龙族以外的「艮神鬼」怪兽加入手卡。
-- ③：这张卡作为「艮神鬼」同调怪兽的同调素材送去墓地的场合，以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化函数：依次注册三个效果——e1为①的特殊召唤规则（手卡中适用的特殊召唤手续，不可复制，1回合1次），e2为②的起动效果（从卡组检索「艮神鬼」怪兽加入手卡），e3为③的诱发选发效果（作为同调素材送墓时以自己墓地通常陷阱为对象盖放）
function s.initial_effect(c)
	-- ①：这张卡可以把自己场上1张里侧表示卡给对方观看并回到手卡·额外卡组，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1只幻龙族以外的「艮神鬼」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为「艮神鬼」同调怪兽的同调素材送去墓地的场合，以自己墓地1张通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 特殊召唤代价的过滤函数：自己场上里侧表示的卡，且能作为代价回到手卡或额外卡组，并且该卡离场后自己还有可用的主要怪兽区
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 判定这张里侧表示卡离场后，自己场上是否仍有可用的主要怪兽区（数量大于0）
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①的特殊召唤手续的条件函数：非检测阶段返回true；检测阶段判断自己场上是否存在满足代价条件的里侧表示卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1张满足代价条件（里侧表示且可回手卡·额外卡组并腾出怪兽区）的卡
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- ①的特殊召唤手续的目标函数：取出所有满足代价条件的里侧表示卡，提示并让用户选择其中1张作为代价；选中则记录到标签对象并返回true，否则返回false
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上所有满足代价条件（里侧表示、可回手卡·额外卡组、能腾出怪兽区）的卡
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 向玩家发送选择提示：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①的特殊召唤手续的处理：取出记录的代价卡，向对方展示后将其回到持有者手卡·额外卡组，完成特殊召唤手续
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把作为代价的里侧表示卡给对方观看（确认）
	Duel.ConfirmCards(1-tp,g)
	-- 以特殊召唤的原因将作为代价的卡送回持有者手卡或额外卡组
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 检索目标的过滤函数：幻龙族以外的「艮神鬼」怪兽，且能加入手卡
function s.thfilter(c)
	return not c:IsRace(RACE_WYRM) and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标函数：发动检测阶段确认卡组中存在满足条件的怪兽；并设置本连锁的操作信息为从卡组回手牌1张
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查自己卡组中是否存在至少1只满足条件的怪兽（幻龙族以外的「艮神鬼」怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：分类为回手牌，预计从卡组把1张卡加入手卡（处理时才能确定具体卡片）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：提示后让玩家从卡组选1只满足条件的怪兽，将其加入手卡并向对方展示确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的怪兽（幻龙族以外的「艮神鬼」怪兽）
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件：这张卡作为「艮神鬼」怪兽的同调召唤的素材被送去墓地（原因卡是「艮神鬼」字段）
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsSetCard(0x1e4)
end
-- 盖放目标的过滤函数：自己墓地中可盖放的通常陷阱卡
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- ③效果的目标函数：限定对象须为自己墓地的通常陷阱卡；发动检测阶段确认墓地存在满足条件的可对象卡，提示并选择1张为对象，设置连锁操作信息为离开墓地1张
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 发动条件检测：检查自己墓地中是否存在至少1张能成为对象的通常陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 以自己墓地1张满足条件的通常陷阱卡为效果对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：分类为离开墓地，对象的卡1张将从墓地被处理
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的处理：取得对象卡，确认其仍与当前连锁相关且不受王家长眠之谷影响后，将其在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（那张通常陷阱卡）
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前连锁相关联，并且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象的那张通常陷阱卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
