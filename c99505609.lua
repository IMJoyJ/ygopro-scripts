--ビンゴカード
local s,id,o=GetID()
-- 初始化卡片效果：注册①发动时全纵列卡片破坏与双方抽卡效果、②墓地发动整行卡片破坏与持有人抽卡效果
function s.initial_effect(c)
	-- ①：以场上1只同一纵列的所有区域都有卡存在的怪兽为对象才能发动。那只怪兽以及那只怪兽同一纵列的所有卡破坏。那之后，双方玩家各抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。选自己或对方1个5个区域都有卡存在的怪兽区域或魔法与陷阱区域。那个区域的所有卡破坏。那之后，那个区域的控制者抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
-- 目标过滤条件：怪兽区域中同一纵列所有区域均有卡存在的怪兽
function s.colfilter(c)
	if not (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)) then return false end
	if c:GetSequence()>=5 then
		return c:GetColumnGroupCount()==4
	end
	return c:IsAllColumn()
end
-- 区域过滤条件：主要怪兽区域或魔法与陷阱区域（格子序号0-4）
function s.zonefilter(c)
	return c:GetSequence()<5
end
-- 判断玩家的5个主要怪兽区域是否全被占用
function s.fullmzone(p)
	-- 检查玩家主要怪兽区域的卡片数量是否为5张
	return Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil):GetCount()==5
end
-- 判断玩家的5个魔法与陷阱区域是否全被占用
function s.fullszone(p)
	-- 检查玩家魔法与陷阱区域的卡片数量是否为5张
	return Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil):GetCount()==5
end
-- 判断玩家是否有满员的整行区域且允许抽2张卡
function s.canrow(p)
	-- 判断玩家主要怪兽区或魔陷区是否满员且该玩家可抽2张卡
	return (s.fullmzone(p) or s.fullszone(p)) and Duel.IsPlayerCanDraw(p,2)
end
-- 获取指定玩家满员整行区域内的所有卡片
function s.rowdesgroup(p)
	local g=Group.CreateGroup()
	if s.fullmzone(p) then
		-- 合并玩家主要怪兽区域的所有卡
		g:Merge(Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil))
	end
	if s.fullszone(p) then
		-- 合并玩家魔法与陷阱区域的所有卡
		g:Merge(Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil))
	end
	return g
end
-- ①效果发动准备：检查目标怪兽及双方抽卡条件
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在符合全纵列条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查双方玩家是否均能抽1张卡
		and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	local g=Group.CreateGroup()
	-- 获取场上所有符合全纵列条件的怪兽
	local rg=Duel.GetMatchingGroup(s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历所有符合条件的怪兽以收集破坏目标组
	for tc in aux.Next(rg) do
		g:Merge(tc:GetColumnGroup())
		g:AddCard(tc)
	end
	-- 设置连锁操作信息：破坏目标卡及其同纵列的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：双方玩家各抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- ①效果处理：选卡破坏同纵列卡片，之后双方各抽1张
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只符合全纵列条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	-- 显示选中的目标卡片
	Duel.HintSelection(g)
	local dg=tc:GetColumnGroup()
	dg:Merge(g)
	-- 成功破坏选中的怪兽及其同纵列所有卡片时
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
		-- 分隔效果处理逻辑
		Duel.BreakEffect()
		-- 自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 对方抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
-- ②效果发动准备：选择要破坏满员行并抽卡的玩家
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.canrow(tp)
	local b2=s.canrow(1-tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择作用于自己还是对方满员行
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	local p=op==1 and tp or 1-tp
	local g=s.rowdesgroup(p)
	-- 设置连锁操作信息：破坏5张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,5,0,0)
	-- 设置连锁操作信息：指定玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,2)
end
-- ②效果处理：破坏满员的整行卡片，之后该玩家抽2张卡
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()==1 and tp or 1-tp
	local bm,bs=s.fullmzone(p),s.fullszone(p)
	local zop=0
	if bm and bs then
		-- 若主要怪兽区和魔陷区均满员，由玩家选择破坏哪一行
		zop=aux.SelectFromOptions(tp,
			{bm,aux.Stringid(id,4),1},
			{bs,aux.Stringid(id,5),2})
	elseif bm then zop=1
	elseif bs then zop=2
	else return end
	local g=Group.CreateGroup()
	if zop==1 then
		-- 获取该玩家主要怪兽区域的所有卡
		g=Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil)
	else
		-- 获取该玩家魔法与陷阱区域的所有卡
		g=Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil)
	end
	-- 成功破坏选定区域的全部5张卡时
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)==5 then
		-- 分隔效果处理逻辑
		Duel.BreakEffect()
		-- 让指定区域的控制者抽2张卡
		Duel.Draw(p,2,REASON_EFFECT)
	end
end
