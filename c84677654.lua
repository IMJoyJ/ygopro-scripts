--大金星！？
-- 效果：
-- 宣言从1到12的任意等级才能发动。双方玩家各自进行1次投掷硬币，都是表出现的场合，自己场上表侧表示存在的全部怪兽的等级变成宣言的等级。都是里出现的场合，自己失去宣言的等级数值×500基本分。
function c84677654.initial_effect(c)
	-- 宣言从1到12的任意等级才能发动。双方玩家各自进行1次投掷硬币，都是表出现的场合，自己场上表侧表示存在的全部怪兽的等级变成宣言的等级。都是里出现的场合，自己失去宣言的等级数值×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c84677654.target)
	e1:SetOperation(c84677654.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选场上表侧表示且拥有等级的怪兽
function c84677654.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 效果发动的目标处理：检查发动条件，让玩家宣言等级并设置投硬币的操作信息
function c84677654.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在至少1只表侧表示且有等级的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84677654.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求宣言一个等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让发动效果的玩家宣言一个1到12的等级
	local lv=Duel.AnnounceLevel(tp)
	-- 将宣言的等级作为效果的目标参数保存
	Duel.SetTargetParam(lv)
	-- 设置操作信息：包含双方玩家共投掷2次硬币的效果分类
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,PLAYER_ALL,2)
end
-- 效果处理：获取宣言的等级，双方进行硬币投掷，并根据投掷结果改变怪兽等级或扣除LP
function c84677654.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时宣言并保存的等级数值
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 让发动效果的玩家进行1次投掷硬币
	local coin1=Duel.TossCoin(tp,1)
	-- 让对方玩家进行1次投掷硬币
	local coin2=Duel.TossCoin(1-tp,1)
	if coin1==1 and coin2==1 then
		-- 获取自己场上当前所有表侧表示且有等级的怪兽
		local g=Duel.GetMatchingGroup(c84677654.cfilter,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- 自己场上表侧表示存在的全部怪兽的等级变成宣言的等级
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	elseif coin1==0 and coin2==0 then
		-- 获取发动效果玩家的当前基本分
		local lp=Duel.GetLP(tp)
		-- 扣除发动效果玩家 宣言的等级×500 的基本分
		Duel.SetLP(tp,lp-lv*500)
	end
end
