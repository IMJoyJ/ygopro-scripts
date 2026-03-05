--スペーシア・ギフト
-- 效果：
-- 自己场上表侧表示存在的名字带有「新空间侠」的怪兽每有1种类，从自己卡组抽1张卡。
function c1539051.initial_effect(c)
	-- 效果原文：自己场上表侧表示存在的名字带有「新空间侠」的怪兽每有1种类，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1539051.target)
	e1:SetOperation(c1539051.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：返回场上表侧表示且名字带有「新空间侠」的怪兽
function c1539051.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1f)
end
-- 效果处理时点：计算满足条件的怪兽数量并检查是否可以抽卡
function c1539051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检索满足条件的场上怪兽组
		local g=Duel.GetMatchingGroup(c1539051.gfilter,tp,LOCATION_MZONE,0,nil)
		local ct=c1539051.count_unique_code(g)
		e:SetLabel(ct)
		-- 判断是否满足抽卡条件
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	-- 设置效果对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果对象参数为计算出的怪兽数量
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果发动时点：执行抽卡操作
function c1539051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 检索满足条件的场上怪兽组
	local g=Duel.GetMatchingGroup(c1539051.gfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c1539051.count_unique_code(g)
	-- 让玩家以效果原因抽指定数量的卡
	Duel.Draw(p,ct,REASON_EFFECT)
end
-- 计算怪兽组中不同卡号的数量
function c1539051.count_unique_code(g)
	local check={}
	local count=0
	local tc=g:GetFirst()
	while tc do
		for i,code in ipairs({tc:GetCode()}) do
			if not check[code] then
				check[code]=true
				count=count+1
			end
		end
		tc=g:GetNext()
	end
	return count
end
