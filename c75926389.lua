--AtoZエナジーロード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把魔法·陷阱·怪兽的效果发动时才能发动。自己抽出自己场上的8星以上而机械族·光属性的融合怪兽的数量。
-- ②：自己准备阶段，把墓地的这张卡除外才能发动。包含同盟怪兽的自己的除外状态的最多6只机械族·光属性怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动时抽卡）和②效果（准备阶段墓地除外回收）
function s.initial_effect(c)
	-- ①：对方把魔法·陷阱·怪兽的效果发动时才能发动。自己抽出自己场上的8星以上而机械族·光属性的融合怪兽的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段，把墓地的这张卡除外才能发动。包含同盟怪兽的自己的除外状态的最多6只机械族·光属性怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tdcon)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION
-- ①效果的发动条件：对方发动了卡的效果
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤条件：自己场上表侧表示的8星以上、机械族·光属性的融合怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
end
-- ①效果的发动准备（Target）：检查自己场上是否存在符合条件的怪兽且自己可以抽卡，并设置抽卡玩家和抽卡数量
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上符合条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 检查可行性：数量大于0且玩家可以抽对应数量的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为抽卡数量
	Duel.SetTargetParam(ct)
	-- 声明该效果的操作信息为：玩家tp抽ct张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ①效果的处理（Operation）：根据自己场上符合条件的怪兽数量，让对应玩家抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前自己场上符合条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 玩家p因效果抽ct张卡
	Duel.Draw(p,ct,REASON_EFFECT)
end
-- ②效果的发动条件：自己的回合
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：除外状态的表侧表示、机械族·光属性且能回到卡组的怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- ②效果的发动准备（Target）：检查除外状态是否存在符合条件的同盟怪兽，并声明回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：除外状态是否存在至少1只符合条件的同盟怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 声明该效果的操作信息为：将除外状态的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
-- 过滤条件：除外状态的表侧表示、机械族·光属性、同盟怪兽且能回到卡组
function s.cfilter(c)
	return c:IsType(TYPE_UNION) and c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- 组检查函数：所选的卡片组中必须包含至少1张符合条件的同盟怪兽
function s.gcheck(g,tp)
	return g:IsExists(s.cfilter,1,nil)
end
-- ②效果的处理（Operation）：选择除外状态的最多6只机械族·光属性怪兽（必须包含同盟怪兽）回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外状态所有符合条件的机械族·光属性怪兽
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,true,1,6,tp)
	if sg then
		-- 显式提示所选择的卡片
		Duel.HintSelection(sg)
		-- 将选择的卡片送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
