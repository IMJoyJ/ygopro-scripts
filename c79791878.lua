--光の黄金櫃
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡只要在魔法与陷阱区域存在，不会被怪兽的效果破坏。
-- ②：自己主要阶段才能发动。除「光之黄金柜」外的有「光之黄金柜」的卡名记述的1张卡从卡组加入手卡。
-- ③：对方从墓地把怪兽特殊召唤的场合，从手卡丢弃1张魔法卡，以那之内的1只为对象才能发动。那只怪兽送去墓地。
local s,id,o=GetID()
-- 初始化函数，用于定义并注册卡片的所有效果
function s.initial_effect(c)
	-- 将「光之黄金柜」的卡片密码注册到该卡的关联卡片列表中，以便其他卡片检测
	aux.AddCodeList(c,79791878)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡只要在魔法与陷阱区域存在，不会被怪兽的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indesval)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。除「光之黄金柜」外的有「光之黄金柜」的卡名记述的1张卡从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.srtg)
	e3:SetOperation(s.srop)
	c:RegisterEffect(e3)
	-- ③：对方从墓地把怪兽特殊召唤的场合，从手卡丢弃1张魔法卡，以那之内的1只为对象才能发动。那只怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.gycon)
	e4:SetCost(s.gycost)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
	-- 注册一个合并延迟事件，用于将同一时点内发生的多只怪兽特殊召唤事件合并为单次自定义事件触发
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
end
-- 破坏抗性效果的过滤函数，判定破坏源是否为怪兽的效果
function s.indesval(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 检索效果的过滤函数，筛选卡组中除「光之黄金柜」以外、记述了「光之黄金柜」卡名且能加入手牌的卡片
function s.srfilter(c)
	-- 判定卡片是否记述了「光之黄金柜」卡名、可以加入手牌，且卡名不等于「光之黄金柜」
	return aux.IsCodeListed(c,id) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果②（检索效果）的发动准备与合法性检测函数
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检测自己卡组中是否存在至少1张满足检索条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索效果）的效果处理函数
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的触发条件过滤函数，筛选由对方从墓地特殊召唤成功、且能送去墓地的怪兽
function s.gyfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsSummonPlayer(1-tp) and c:IsAbleToGrave() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 效果③的发动条件函数，判定特殊召唤成功的卡片中是否存在满足条件的怪兽
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gyfilter,1,nil,tp)
end
-- 效果③的手牌Cost过滤函数，筛选手牌中可以丢弃的魔法卡
function s.disfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果③的发动代价（Cost）处理函数
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检测自己手牌中是否存在至少1张可以丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌中的魔法卡作为发动的代价
	Duel.DiscardHand(tp,s.disfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果③（送去墓地）的目标选择与合法性检测函数
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.gyfilter,nil,tp)
	-- 判定成为效果对象的目标是否仍在怪兽区，且属于本次特殊召唤的怪兽组
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.IsInGroup(chkc,g) end
	-- 步骤0：检测场上是否存在至少1个符合条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 将唯一符合条件的怪兽直接设为当前连锁的效果对象
		Duel.SetTargetCard(sg)
	else
		-- 给发动效果的玩家发送提示信息，提示其选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从符合条件的怪兽中选择1只作为效果对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置连锁处理的操作信息，表示该效果会将选中的1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,1,0,0)
end
-- 效果③（送去墓地）的效果处理函数
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
