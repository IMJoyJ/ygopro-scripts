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
-- 定义效果的发动准备（Target）函数，用于检查发动条件并向连锁中注册预期的操作信息
function c71625222.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有怪兽，用于后续判断是否需要注册破坏的操作信息
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	-- 向连锁中注册投掷硬币的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	if #g>0 then
		-- 若对方场上有怪兽，则向连锁中注册破坏卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	end
end
-- 定义效果的处理（Operation）函数，执行投硬币猜测并根据结果进行破坏和伤害处理
function c71625222.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让发动效果的玩家宣言硬币的正反面（进行猜测）
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币，并获取投掷结果
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 若猜中（宣言与结果相同），获取对方场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 将获取到的对方场上的怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
		-- 触发自定义事件，用于其他卡片（如配合卡）检测时间魔术师成功发动效果的时点
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+71625222,e,0,0,tp,0)
	else
		-- 若猜错（宣言与结果不同），获取自己场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 将获取到的自己场上的怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
		-- 获取刚才因效果实际被破坏的卡片组
		local dg=Duel.GetOperatedGroup()
		local sum=0
		-- 遍历实际被破坏的卡片组，用于累计这些怪兽的攻击力
		for c in aux.Next(dg) do
			sum=sum+math.max(c:GetAttack(),0)
		end
		if sum>0 then
			-- 给与自己受到破坏的怪兽攻击力合计数值一半的伤害
			Duel.Damage(tp,math.floor(sum/2),REASON_EFFECT)
		end
	end
end
