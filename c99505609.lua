--ビンゴカード
local s,id,o=GetID()
-- 卡片的初始化处理，定义各个效果
function s.initial_effect(c)
	-- ①：以场上纵列全满的1只怪兽为对象才能发动。该怪兽所在纵列的卡全部破坏，双方各抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。把主要怪兽区域或魔法与陷阱区域全满的1个玩家的那个区域的卡全部破坏，那个玩家抽2张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 效果发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断怪兽所在纵列是否全满
function s.colfilter(c)
	if not (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER)) then return false end
	if c:GetSequence()>=5 then
		return c:GetColumnGroupCount()==4
	end
	return c:IsAllColumn()
end
-- 过滤条件：判断卡片是否在主要区域（非额外怪兽区或场地区域）
function s.zonefilter(c)
	return c:GetSequence()<5
end
-- 判断指定玩家的主要怪兽区域是否全满
function s.fullmzone(p)
	-- 返回指定玩家主要怪兽区域的卡片数量是否达到5张
	return Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil):GetCount()==5
end
-- 判断指定玩家的魔法与陷阱区域是否全满
function s.fullszone(p)
	-- 返回指定玩家魔法与陷阱区域的卡片数量是否达到5张
	return Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil):GetCount()==5
end
-- 判断指定玩家是否有一排区域全满并且可以抽2张卡
function s.canrow(p)
	-- 返回玩家的怪兽区域或魔陷区域是否全满，且该玩家能够抽2张卡
	return (s.fullmzone(p) or s.fullszone(p)) and Duel.IsPlayerCanDraw(p,2)
end
-- 获取指定玩家全满区域内的所有卡
function s.rowdesgroup(p)
	local g=Group.CreateGroup()
	if s.fullmzone(p) then
		-- 如果主要怪兽区域全满，则将该区域的所有卡加入卡片组
		g:Merge(Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil))
	end
	if s.fullszone(p) then
		-- 如果魔法与陷阱区域全满，则将该区域的所有卡加入卡片组
		g:Merge(Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil))
	end
	return g
end
-- 效果目标：检查是否可以发动破坏纵列效果
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果是检查阶段，判断场上是否存在纵列全满的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且判断双方玩家是否都可以抽1张卡
		and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	local g=Group.CreateGroup()
	-- 获取场上所有纵列全满的怪兽
	local rg=Duel.GetMatchingGroup(s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历所有纵列全满的怪兽
	for tc in aux.Next(rg) do
		g:Merge(tc:GetColumnGroup())
		g:AddCard(tc)
	end
	-- 设置操作信息为破坏选定纵列的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息为双方玩家各抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理：破坏选中的纵列并让双方抽卡
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只纵列全满的怪兽作为对象
	local g=Duel.SelectMatchingCard(tp,s.colfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	-- 手动显示对象卡片被选择的动画
	Duel.HintSelection(g)
	local dg=tc:GetColumnGroup()
	dg:Merge(g)
	-- 如果纵列上的卡被破坏且数量大于0
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
		-- 打断效果处理，产生不同时处理的节点
		Duel.BreakEffect()
		-- 自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 对方抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
-- 效果目标：选择符合条件的玩家全满区域进行破坏和抽卡操作
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.canrow(tp)
	local b2=s.canrow(1-tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择处理的对象（自己或对方的全满区域）
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	local p=op==1 and tp or 1-tp
	local g=s.rowdesgroup(p)
	-- 设置操作信息为破坏全满区域的5张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,5,0,0)
	-- 设置操作信息为目标玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,p,2)
end
-- 效果处理：破坏全满区域的卡并让目标玩家抽卡
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()==1 and tp or 1-tp
	local bm,bs=s.fullmzone(p),s.fullszone(p)
	local zop=0
	if bm and bs then
		-- 让玩家选择要破坏怪兽区域还是魔陷区域的卡
		zop=aux.SelectFromOptions(tp,
			{bm,aux.Stringid(id,4),1},
			{bs,aux.Stringid(id,5),2})
	elseif bm then zop=1
	elseif bs then zop=2
	else return end
	local g=Group.CreateGroup()
	if zop==1 then
		-- 获取目标玩家主要怪兽区域的所有卡
		g=Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_MZONE,0,nil)
	else
		-- 获取目标玩家魔法与陷阱区域的所有卡
		g=Duel.GetMatchingGroup(s.zonefilter,p,LOCATION_SZONE,0,nil)
	end
	-- 如果破坏成功并且实际破坏了5张卡
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)==5 then
		-- 打断效果处理，产生不同时处理的节点
		Duel.BreakEffect()
		-- 让目标玩家抽2张卡
		Duel.Draw(p,2,REASON_EFFECT)
	end
end
