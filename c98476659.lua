--怠慢な壺
-- 效果：
-- ①：自己抽出对方场上的卡的数量。抽2张以上的场合，再选那个数量－1张的自己手卡用喜欢的顺序回到卡组下面。这张卡的发动后，直到回合结束时自己不能把「怠慢之壶」发动。
local s,id=GetID()
-- 初始化魔法卡效果，注册卡片发动时的主要效果
function s.initial_effect(c)
	-- ①：自己抽出对方场上的卡的数量。抽2张以上的场合，再选那个数量－1张的自己手卡用喜欢的顺序回到卡组下面。这张卡的发动后，直到回合结束时自己不能把「怠慢之壶」发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数，检查本回合自身是否没有被发动过
function s.condition(_,tp)
	-- 检查该回合玩家是否没有注册过该卡片已发动的Flag，确保同名卡一回合只能发动一次
	return Duel.GetFlagEffect(tp,id)==0
end
-- 效果发动的Target函数，计算对方场上的卡片数量，进行能否抽卡的合法性检查，并设置效果连锁的相关参数和操作信息
function s.target(_,tp,_,_,_,_,_,_,chk)
	-- 获取对方场上卡片的总数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 当chk为0时，检查对方场上是否有卡，以及自己是否可以抽取相应数量的卡片
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 将当前处理的连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前处理的连锁的对象参数设置为对方场上卡片数量
	Duel.SetTargetParam(ct)
	-- 设置本效果包含抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果发动的Operation函数，注册卡片已发动限制，计算数量并执行抽卡，若抽卡数量大于等于2，则选择相应数量的手牌按顺序放回卡组底端
function s.activate(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 为玩家注册本回合已发动「怠慢之壶」的Flag，在回合结束时重置，以此实现同名卡一回合只能发动一次的限制
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
	-- 获取连锁信息中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetFieldGroupCount(p,0,LOCATION_ONFIELD)
	if ct<=0 then return end
	-- 让目标玩家抽取对方场上卡片数量的卡片，并返回实际抽取的数量
	local drawn=Duel.Draw(p,ct,REASON_EFFECT)
	if drawn>=2 then
		local ret=drawn-1
		-- 中断效果处理，使得之后的手牌回卡组操作与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 向玩家发送请选择要放回卡组的卡的提示
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家选择所抽卡片数量减1张的手卡
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,ret,ret,nil)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(p)
		-- 将选择的手牌以玩家自己决定的顺序放回卡组最下方
		aux.PlaceCardsOnDeckBottom(p,g)
	end
end
