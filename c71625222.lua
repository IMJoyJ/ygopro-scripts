--時の魔術師
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，对方场上的怪兽全部破坏。猜错的场合，自己场上的怪兽全部破坏，自己受到表侧表示破坏的怪兽的攻击力合计数值一半的伤害。
function c71625222.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，对方场上的怪兽全部破坏。猜错的场合，自己场上的怪兽全部破坏，自己受到表侧表示破坏的怪兽的攻击力合计数值一半的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71625222,0))  --"猜硬币"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c71625222.destg)
	e1:SetOperation(c71625222.desop)
	c:RegisterEffect(e1)
end
-- 投掷硬币破坏效果发动准备与操作信息设置
function c71625222.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的怪兽
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：投掷1次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	if #g>0 then
		-- 设置操作信息：破坏卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	end
end
-- 效果处理：玩家猜测硬币正反面并投掷硬币，猜中破坏对方场上全部怪兽，猜错破坏己方场上全部怪兽并受伤害
function c71625222.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 投掷1次硬币
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 获取对方场上的全部怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 破坏对方场上的全部怪兽
		Duel.Destroy(g,REASON_EFFECT)
		-- 触发自定义事件
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+71625222,e,0,0,tp,0)
	else
		-- 获取自己场上的全部怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 破坏自己场上的全部怪兽
		Duel.Destroy(g,REASON_EFFECT)
		-- 筛选出被破坏前是表侧表示的怪兽
		local dg=Duel.GetOperatedGroup():Filter(Card.IsPreviousPosition,nil,POS_FACEUP)
		local sum=0
		-- 遍历破坏前表侧表示的怪兽计算原本在场攻击力总和
		for c in aux.Next(dg) do
			sum=sum+math.max(c:GetPreviousAttackOnField(),0)
		end
		if sum>0 then
			-- 自己受到表侧表示破坏怪兽攻击力合计一半的伤害
			Duel.Damage(tp,math.floor(sum/2),REASON_EFFECT)
		end
	end
end
