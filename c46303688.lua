--ルーレットボマー
-- 效果：
-- 在自己的每回合的主要阶段可以掷2次骰子，在掷出的点数中选择1个，破坏场上1只表侧表示的与此点数相同等级的怪兽。
function c46303688.initial_effect(c)
	-- 创建效果，设置效果描述为“掷骰子”，分类为破坏和骰子效果，类型为起动效果，适用区域为主怪兽区，限制每回合只能发动一次，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46303688,0))  --"掷骰子"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c46303688.target)
	e1:SetOperation(c46303688.activate)
	c:RegisterEffect(e1)
end
-- 目标函数，检查是否可以发动效果，并设置操作信息为玩家投掷2次骰子
function c46303688.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为骰子效果，投掷次数为2
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
-- 破坏过滤函数，用于筛选表侧表示且等级等于指定值的怪兽
function c46303688.dfilter(c,lv)
	return c:IsFaceup() and c:IsLevel(lv)
end
-- 发动函数，投掷两次骰子，根据点数选择一个作为目标等级，然后选择场上符合条件的怪兽进行破坏
function c46303688.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷两次骰子，返回两个骰子的结果
	local d1,d2=Duel.TossDice(tp,2)
	local sel=d1
	if d1>d2 then d1,d2=d2,d1 end
	if d1~=d2 then
		-- 如果两次骰子点数不同，则让玩家从两个点数中选择一个作为目标等级
		sel=Duel.AnnounceNumber(tp,d1,d2)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示且等级等于目标等级的怪兽作为破坏对象
	local dg=Duel.SelectMatchingCard(tp,c46303688.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,sel)
	if dg:GetCount()>0 then
		-- 将选中的怪兽以效果原因进行破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
