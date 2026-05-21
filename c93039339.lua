--厄災の星ティ・フォン
-- 效果：
-- 12星怪兽×2
-- 这张卡在对方从额外卡组把2只以上的怪兽特殊召唤的回合以及那下个回合也能在自己场上的攻击力最高的怪兽上面重叠来超量召唤。这个方法特殊召唤过的回合，自己不能把怪兽召唤·特殊召唤。
-- ①：只要超量召唤的这张卡在怪兽区域存在，双方不能把攻击力3000以上的怪兽的效果发动。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。场上1只怪兽回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册超量召唤手续、全局特殊召唤检测、特殊召唤限制、永续效果（封锁3000以上攻击力怪兽效果发动）以及起动效果（弹回手牌）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,12,2,s.mfilter,aux.Stringid(id,0),2,s.altop)  --"在自己场上的攻击力最高的怪兽上面重叠来超量召唤"
	if not s.global_check then
		s.global_check=true
		-- 这张卡在对方从额外卡组把2只以上的怪兽特殊召唤的回合以及那下个回合也能在自己场上的攻击力最高的怪兽上面重叠来超量召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.chk)
		-- 注册全局环境效果，用于监控双方玩家从额外卡组特殊召唤怪兽的情况。
		Duel.RegisterEffect(ge1,0)
	end
	-- 这个方法特殊召唤过的回合，自己不能把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.lscon)
	e1:SetOperation(s.lsop)
	c:RegisterEffect(e1)
	-- ①：只要超量召唤的这张卡在怪兽区域存在，双方不能把攻击力3000以上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.lecon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。场上1只怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检测是否为对方玩家从额外卡组特殊召唤的怪兽。
function s.chkfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 全局特殊召唤检测函数，记录每个玩家在当前回合从额外卡组特殊召唤怪兽的数量，若达到2只以上则注册对应的标识。
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tc=eg:GetFirst()
		while tc do
			if s.chkfilter(tc,p) then
				-- 为玩家注册一个回合内从额外卡组特殊召唤怪兽的计数标识。
				Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
			end
			tc=eg:GetNext()
		end
		-- 判断该玩家在当前回合从额外卡组特殊召唤怪兽的数量是否达到2只或以上。
		if Duel.GetFlagEffect(p,id)>1 then
			-- 注册一个持续2个回合（本回合及下个回合）的标识，满足提·丰的特殊召唤条件。
			Duel.RegisterFlagEffect(p,id+o,RESET_PHASE+PHASE_END,0,2)
		end
	end
end
-- 过滤函数，筛选出自己场上攻击力最高的表侧表示怪兽。
function s.mfilter(c,e,tp)
	-- 获取自己场上表侧表示怪兽中攻击力最高的怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and #g>0 and g:IsContains(c)
end
-- 替代超量召唤的操作函数，检查是否满足召唤条件，并在成功召唤时为自身注册标识。
function s.altop(e,tp,chk)
	-- 在召唤手续的准备阶段，检查对方是否在当前回合或上个回合从额外卡组特殊召唤过2只以上的怪兽。
	if chk==0 then return Duel.GetFlagEffect(tp,id+o)>0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- 召唤限制效果的触发条件，检查自身是否是通过替代方法特殊召唤的。
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 召唤限制效果的处理函数，在当前回合对自身施加不能召唤·特殊召唤怪兽的限制。
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个方法特殊召唤过的回合，自己不能把怪兽召唤·特殊召唤。①：只要超量召唤的这张卡在怪兽区域存在，双方不能把攻击力3000以上的怪兽的效果发动。②：1回合1次，把这张卡1个超量素材取除才能发动。场上1只怪兽回到手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤怪兽的玩家效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册不能通常召唤怪兽的玩家效果。
	Duel.RegisterEffect(e2,tp)
end
-- 效果1的启用条件，检查这张卡是否为超量召唤。
function s.lecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果1的限制目标，过滤出攻击力在3000以上的怪兽的效果发动。
function s.aclimit(e,te,tp)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsAttackAbove(3000)
end
-- 效果2的消耗，取除这张卡的1个超量素材。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果2的靶向与操作信息设置，确认场上是否存在可以回到手牌的怪兽。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以回到手牌的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁处理的操作信息，表示该效果将使场上的1只怪兽回到手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果2的处理函数，让玩家选择场上1只怪兽并将其送回手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上1只可以回到手牌的怪兽。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 闪烁显示被选中的怪兽，向双方玩家展示。
		Duel.HintSelection(g)
		-- 将选中的怪兽送回持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
