--眠らない街の『レイズ・ムーン』
-- 效果：
-- ①：自己场上的7星「盈彩月夜」怪兽在1回合各有1次不会被效果破坏。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●选自己1张手卡回到卡组最上面或最下面。那之后，自己抽1张。
-- ●自己场上有魔法师族「盈彩月夜」超量怪兽存在的场合才能发动。自己抽1张。
-- ③：自己·对方的结束阶段发动。自己的墓地·除外状态的「盈彩月夜」卡全部回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动、7星「盈彩月夜」怪兽效破抗性、二选一抽卡以及结束阶段墓地·除外卡回到卡组效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的7星「盈彩月夜」怪兽在1回合各有1次不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ②：1回合1次，可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"发动"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	-- ③：自己·对方的结束阶段发动。自己的墓地·除外状态的「盈彩月夜」卡全部回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"回到卡组"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的7星「盈彩月夜」怪兽
function s.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1ec) and c:IsLevel(7)
end
-- 设置怪兽每回合各有1次不会被效果破坏
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 过滤自己场上表侧表示的魔法师族「盈彩月夜」超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1ec) and c:IsType(TYPE_XYZ)
end
-- 二选一抽卡效果的发动条件检查、选项分支选择与操作信息设置
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在可以回到卡组的卡
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
		-- 检查自己是否可以抽1张卡
		and Duel.IsPlayerCanDraw(tp,1)
	-- 检查自己场上是否存在表侧表示的魔法师族「盈彩月夜」超量怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己是否可以抽1张卡
		and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足条件的选项中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"回卡组并抽卡"
			{b2,aux.Stringid(id,2),2})  --"抽卡"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
		end
		-- 设置操作信息：自己抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DRAW)
		end
		-- 设置抽卡操作的目标玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 设置抽卡操作的目标参数为1张
		Duel.SetTargetParam(1)
		-- 设置操作信息：目标玩家抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 根据选择的选项执行手卡回卡组抽卡或直接抽卡的效果处理
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选自己1张手卡回到卡组
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			local res=0
			-- 让玩家选择将卡放到卡组最上面或最下面
			if Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0 then  --"卡组上面/卡组下面"
				-- 将选中的手卡放到卡组最上面
				res=Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将选中的手卡放到卡组最下面
				res=Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
			if res~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
				-- 分隔手卡回卡组与抽卡的处理时点
				Duel.BreakEffect()
				-- 自己抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取目标玩家与抽卡数量参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 目标玩家抽指定数量的卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
-- 过滤墓地·除外状态表侧表示可以回到卡组的「盈彩月夜」卡
function s.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ec) and c:IsAbleToDeck()
end
-- 结束阶段卡片回卡组效果的发动目标判定及操作信息设置
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己的墓地·除外状态满足条件的「盈彩月夜」卡片组
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		-- 设置操作信息：将墓地·除外状态的「盈彩月夜」卡全部回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),LOCATION_GRAVE+LOCATION_REMOVED,0)
	end
end
-- 结束阶段将自己墓地·除外状态的「盈彩月夜」卡全部洗回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己的墓地·除外状态满足条件的「盈彩月夜」卡片组
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		-- 检查目标卡片是否受王家长眠之谷影响并进行无效处理
		if aux.NecroValleyNegateCheck(g) then return end
		-- 将卡片全部返回持有者卡组并洗切
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
