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
-- 等级变更过滤条件：自己场上表侧表示且有等级的怪兽
function c84677654.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 卡片发动准备：检查发动条件、宣言等级并设置硬币投掷操作信息
function c84677654.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否存在表侧表示有等级的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84677654.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 由玩家宣言1～12的等级
	local lv=Duel.AnnounceLevel(tp)
	-- 保存宣言的等级参数
	Duel.SetTargetParam(lv)
	-- 设置连锁操作信息：双方玩家进行投硬币共2次
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,PLAYER_ALL,2)
end
-- 卡片效果处理：双方投硬币，均为表侧时改变己方怪兽等级，均为里侧时扣除基本分
function c84677654.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时保存的宣言等级参数
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 己方玩家进行1次投硬币
	local coin1=Duel.TossCoin(tp,1)
	-- 对方玩家进行1次投硬币
	local coin2=Duel.TossCoin(1-tp,1)
	if coin1==1 and coin2==1 then
		-- 获取自己场上所有表侧表示且有等级的怪兽
		local g=Duel.GetMatchingGroup(c84677654.cfilter,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- 效果处理：注册等级变更效果，将怪兽等级变为宣言的等级
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	elseif coin1==0 and coin2==0 then
		-- 获取己方当前基本分
		local lp=Duel.GetLP(tp)
		-- 扣除己方基本分：失去宣言等级数值×500
		Duel.SetLP(tp,lp-lv*500)
	end
end
