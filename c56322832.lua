--転惺竜華－闇巴
-- 效果：
-- ←11 【灵摆】 11→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己不是「龙华」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：对方连锁自己的「龙华」魔法卡的效果的发动来发动的魔法·陷阱·怪兽的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①②③的怪兽效果1回合各能使用1次。
-- ①：把「转惺龙华-暗巴」以外的自己的手卡·场上1只「龙华」怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡被破坏的场合才能发动。自己的卡组·墓地·除外状态的1张「龙华」永续魔法·永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆属性设置、灵摆效果①②以及怪兽效果①②③的注册
function s.initial_effect(c)
	-- 注册灵摆怪兽的基本属性（灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「龙华」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：对方连锁自己的「龙华」魔法卡的效果的发动来发动的魔法·陷阱·怪兽的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ①：把「转惺龙华-暗巴」以外的自己的手卡·场上1只「龙华」怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"破坏效果"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- ③：这张卡被破坏的场合才能发动。自己的卡组·墓地·除外状态的1张「龙华」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))  --"放置魔法陷阱"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id+o*2)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
-- 限制自身只能灵摆召唤「龙华」怪兽的过滤条件函数
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x1c0) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 灵摆效果②的触发条件：对方连锁自己「龙华」魔法卡的效果发动而发动效果，且该效果可以被无效，且本回合尚未适用过此效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ev<1 then return false end
	-- 获取前一个连锁（即被对方连锁的、自己发动的效果）的效果和发动玩家
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return rp==1-tp and p==tp and te and te:GetHandler():IsSetCard(0x1c0) and te:IsActiveType(TYPE_SPELL)
		-- 检查本回合是否尚未适用过该无效效果（确保1回合只能使用1次）
		and Duel.GetFlagEffect(tp,id)==0
		-- 检查当前处理的连锁效果是否可以被无效，且当前未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 灵摆效果②的效果处理：询问玩家是否发动，若发动则无效该效果，并破坏此卡
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否已适用过该效果，并让玩家选择是否适用该效果进行无效
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否适用「转惺龙华-暗巴」的效果来无效？"
		-- 向双方玩家展示此卡发动的动画提示
		Duel.Hint(HINT_CARD,0,id)
		-- 给玩家注册一个持续到回合结束的标识，用于记录本回合已适用过该效果
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 尝试无效当前连锁的效果，若成功则执行后续处理
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理，使后续的破坏处理与无效处理不视为同时进行
			Duel.BreakEffect()
			-- 因效果将灵摆区域的这张卡破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 过滤手卡或场上用于解放的「龙华」怪兽（不含同名卡），且解放后能腾出怪兽区域
function s.spfilter(c,tp)
	-- 检查卡片是否为「龙华」怪兽、不是同名卡，且解放该卡后自己场上有可用的怪兽区域
	return c:IsSetCard(0x1c0) and not c:IsCode(id) and Duel.GetMZoneCount(tp,c)>0
end
-- 怪兽效果①的Cost：解放手卡或场上的一只「龙华」怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可作为Cost解放的、满足条件的「龙华」怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.spfilter,1,REASON_COST,true,e:GetHandler(),tp) end
	-- 玩家选择1只满足条件的「龙华」怪兽作为Cost解放
	local g=Duel.SelectReleaseGroupEx(tp,s.spfilter,1,1,REASON_COST,true,e:GetHandler(),tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 怪兽效果①的Target：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含1张自身卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的Operation：将手卡的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 怪兽效果②的Target：选择场上1张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏的操作信息，包含选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 怪兽效果②的Operation：破坏选中的对象卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏选中的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤卡组、墓地、除外状态中可以表侧表示放置到场上的「龙华」永续魔法·永续陷阱卡
function s.pfilter(c,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x1c0)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 怪兽效果③的Target：检查魔法与陷阱区域是否有空位，以及是否存在可放置的「龙华」永续魔陷
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的卡组、墓地、除外状态中是否存在满足条件的「龙华」永续魔法·永续陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) end
end
-- 怪兽效果③的Operation：选择1张满足条件的「龙华」永续魔陷在场上表侧表示放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家从卡组、墓地（受王家之谷影响）、除外状态中选择1张满足条件的「龙华」永续魔陷
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
	-- 若成功选出卡片，则将其在自己的魔法与陷阱区域表侧表示放置，并适用其效果
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
