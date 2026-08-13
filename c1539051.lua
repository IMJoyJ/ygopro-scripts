--スペーシア・ギフト
-- 效果：
-- 自己场上表侧表示存在的名字带有「新空间侠」的怪兽每有1种类，从自己卡组抽1张卡。
function c1539051.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「新空间侠」的怪兽每有1种类，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1539051.target)
	e1:SetOperation(c1539051.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选出自己场上表侧表示且属于「新空间侠」字段的怪兽。
function c1539051.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1f)
end
-- 效果发动时的判定：统计自己场上满足条件的怪兽种类数ct，若ct大于0且自己可以抽ct张卡则允许发动；随后将对象玩家设为自己、对象参数设为ct，并写入抽卡的操作信息。
function c1539051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有满足gfilter条件（表侧表示且为「新空间侠」）的怪兽组，用于统计种类数。
		local g=Duel.GetMatchingGroup(c1539051.gfilter,tp,LOCATION_MZONE,0,nil)
		local ct=c1539051.count_unique_code(g)
		e:SetLabel(ct)
		-- 返回是否满足发动条件：统计到的种类数ct大于0，并且自己玩家能够抽ct张卡。
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	-- 将当前连锁的对象玩家设为自己，表示该效果以自己为对象玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为之前存储的种类数ct，供处理阶段使用。
	Duel.SetTargetParam(e:GetLabel())
	-- 写入抽卡效果的操作信息：声明本连锁将进行抽卡，对象玩家是自己，预计抽卡张数为之前记录的种类数。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果处理：从连锁信息获取对象玩家p，重新统计当前自己场上满足条件的怪兽种类数ct，然后让p抽ct张卡。
function c1539051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家（即发动时指定的自己），用于决定抽卡玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 处理阶段重新获取当前自己场上满足gfilter条件的怪兽组，以计算实际种类数（场上怪兽可能已变化）。
	local g=Duel.GetMatchingGroup(c1539051.gfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c1539051.count_unique_code(g)
	-- 让对象玩家p以效果原因抽ct张卡，实现抽卡效果。
	Duel.Draw(p,ct,REASON_EFFECT)
end
-- 统计传入怪兽组中不同卡号的数量：遍历每张怪兽，用字典去重记录其当前卡号，最终返回不同卡号的总数，即“种类”数。
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
