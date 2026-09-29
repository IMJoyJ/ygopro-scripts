--レイズ・ムーンの星々
-- 效果：
-- ①：从卡组选「盈彩月夜之群星」以外的1张「盈彩月夜」卡在卡组最上面放置（这个回合，这个卡名的这个效果不能选同名卡）。这张卡的发动后，直到回合结束时双方不能用抽卡以外的方法从卡组把卡加入手卡。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●双方各自抽1张。
-- ●自己场上有魔法师族「盈彩月夜」超量怪兽存在的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动（置顶卡片与封锁检索）以及墓地除外抽卡效果
function s.initial_effect(c)
	-- ①：从卡组选「盈彩月夜之群星」以外的1张「盈彩月夜」卡在卡组最上面放置（这个回合，这个卡名的这个效果不能选同名卡）。这张卡的发动后，直到回合结束时双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 发动代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中本回合未被该效果选择过的同名卡以外的「盈彩月夜」卡
function s.cfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1ec) and not c:IsHasEffect(id,0)
end
-- 效果①的目标判定
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「盈彩月夜」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的操作处理：选卡放置于卡组最上面，并注册双方不能用抽卡以外的方法从卡组把卡加入手卡的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要放置到卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要放置到卡组最上面的卡"
	-- 从卡组选择1张同名卡以外的「盈彩月夜」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的卡移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的1张卡
		Duel.ConfirmDecktop(tp,1)
		-- 这个回合，这个卡名的这个效果不能选同名卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(id)
		e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
		e1:SetTarget(s.ndtg)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全场生效的标记效果：记录本回合被选择的卡名
		Duel.RegisterEffect(e1,0)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时双方不能用抽卡以外的方法从卡组把卡加入手卡。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_TO_HAND)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		-- 设置限制范围为卡组的卡片
		e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册直到回合结束双方不能用抽卡以外方法从卡组把卡加入手卡的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤与选中的卡同名的卡片
function s.ndtg(e,c)
	return c:IsCode(e:GetLabel())
end
-- 过滤场上表侧表示的魔法师族「盈彩月夜」超量怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1ec) and c:IsType(TYPE_XYZ)
end
-- 效果②的目标判定与选项选择
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否均可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
	-- 检查自己场上是否存在魔法师族「盈彩月夜」超量怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自身是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足条件的效果选项中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"双方抽卡"
			{b2,aux.Stringid(id,4),2})  --"自己抽卡"
	e:SetLabel(op)
	if op==1 then
		-- 设置操作信息：双方各自抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	elseif op==2 then
		-- 设置抽卡玩家为自身
		Duel.SetTargetPlayer(tp)
		-- 设置抽卡数量为1张
		Duel.SetTargetParam(1)
		-- 设置操作信息：自身抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果②的操作处理：根据所选分支执行抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 自身抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 对方抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 获取抽卡的玩家与抽卡数量参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行抽卡操作
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
