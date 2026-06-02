--Shade the Obscure
-- 效果：
-- ←11 【灵摆】 11→
-- 自己不是灵摆怪兽不能灵摆召唤（这个效果不会被无效化）。
-- 攻击力1000以下的怪兽特殊召唤的场合（伤害步骤除外）：可以让这张卡回到手卡。「无明者 阴暗」的这个效果1回合只能使用1次。
--  【怪兽效果】
-- 自己灵摆区域有卡存在，这张卡在手卡存在的场合：可以把这张卡特殊召唤。
-- 可以支付1000基本分；自己手卡·场上（表侧表示）的1张灵摆怪兽卡破坏，那之后，可以从卡组把1只灵摆怪兽以表侧加入额外卡组。
-- 「无明者 阴暗」的每个怪兽效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果：注册灵摆怪兽属性，以及灵摆效果和怪兽效果（灵摆召唤限制、回到手卡效果、手卡特殊召唤效果、破坏并加入额外卡组效果）。
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（灵摆召唤、作为魔法卡发动/放置在灵摆区域）
	aux.EnablePendulumAttribute(c)
	-- 自己不是灵摆怪兽不能灵摆召唤（这个效果不会被无效化）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- 攻击力1000以下的怪兽特殊召唤的场合（伤害步骤除外）：可以让这张卡回到手卡。「无明者 阴暗」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.pthcon)
	e2:SetTarget(s.pthtg)
	e2:SetOperation(s.pthop)
	c:RegisterEffect(e2)
	-- 自己灵摆区域有卡存在，这张卡在手卡存在的场合：可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.hspcon)
	e3:SetTarget(s.hsptg)
	e3:SetOperation(s.hspop)
	c:RegisterEffect(e3)
	-- 可以支付1000基本分；自己手卡·场上（表侧表示）的1张灵摆怪兽卡破坏，那之后，可以从卡组把1只灵摆怪兽以表侧加入额外卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 灵摆召唤限制的Target过滤函数：非灵摆怪兽在进行灵摆召唤时返回true（限制其灵摆召唤）
function s.splimit(e,c,tp,sumtp,sumpos)
	if not c then return false end
	return not c:IsType(TYPE_PENDULUM) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤攻击力1000以下的表侧表示怪兽
function s.pthfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1000)
end
-- 回到手卡效果的发动条件函数：检测是否有攻击力1000以下的怪兽特殊召唤成功
function s.pthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pthfilter,1,nil)
end
-- 回到手卡效果的Target目标处理函数
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将此卡回到手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回到手卡效果的Operation具体操作处理函数
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsAbleToHand() then
		-- 将此卡返回持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 手卡特殊召唤效果的发动条件函数
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在卡片
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_PZONE,0,nil)>0
end
-- 手卡特殊召唤效果的Target目标处理函数
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查以当前玩家来看的怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡的此卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 手卡特殊召唤效果的Operation具体操作处理函数
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏与加入额外卡组效果的Cost发动代价处理函数
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000点生命值作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤符合条件的灵摆怪兽卡（手卡或场上表侧表示的灵摆怪兽卡）
function s.desfilter(c)
	return c:GetOriginalType()&TYPE_PENDULUM~=0 and c:IsFaceupEx()
end
-- 过滤卡组中符合条件的可以送去额外卡组的灵摆怪兽
function s.tedfilter(c)
	return c:IsAllTypes(TYPE_PENDULUM+TYPE_MONSTER) and c:IsAbleToExtra()
end
-- 破坏与加入额外卡组效果的Target目标处理函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可破坏的符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 获取符合破坏条件的卡片组
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 检查自己手卡中是否存在未公开的卡片
	if Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(aux.NOT(Card.IsPublic),nil)>0 then
		-- 如果手卡存在未公开卡片，设置可能破坏手卡或场上符合条件卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	else
		if dg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0 then
			-- 如果手卡全部公开，且其中存在符合条件的卡片，设置可能破坏手卡或场上符合条件卡片的操作信息
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
		else
			-- 如果手卡没有符合条件的卡片，设置破坏场上表侧表示卡片的操作信息
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_ONFIELD)
		end
	end
	-- 设置从卡组将卡片表侧表示加入额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 破坏与加入额外卡组效果的Operation具体操作处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从手卡或场上选择1张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		if g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)>0 then
			-- 若选择了场上的卡片，为所选卡片显示选择动画效果
			Duel.HintSelection(g)
		end
		-- 若成功破坏了卡片
		if Duel.Destroy(g,REASON_EFFECT)>0
			-- 并且卡组中存在符合条件的灵摆怪兽
			and Duel.IsExistingMatchingCard(s.tedfilter,tp,LOCATION_DECK,0,1,nil)
			-- 且玩家选择将卡片加入额外卡组
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把卡加入额外卡组？"
			-- 提示玩家选择要加入额外卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))  --"请选择加入额外卡组的卡"
			-- 让玩家从卡组中选择1只符合条件的灵摆怪兽
			local tg=Duel.SelectMatchingCard(tp,s.tedfilter,tp,LOCATION_DECK,0,1,1,nil)
			if tg:GetCount()>0 then
				-- 将被选中的灵摆怪兽表侧表示送去额外卡组
				Duel.SendtoExtraP(tg,tp,REASON_EFFECT)
			end
		end
	end
end
