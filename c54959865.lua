--N・エア・ハミングバード
-- 效果：
-- 对方每有1张手卡，自己回复500基本分。这个效果1回合只能使用1次。
function c54959865.initial_effect(c)
	-- 对方每有1张手卡，自己回复500基本分。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54959865,0))  --"回复LP"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c54959865.target)
	e1:SetOperation(c54959865.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与准备函数
function c54959865.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：对方手卡数量必须大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的操作信息为回复生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 效果处理的执行函数
function c54959865.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算回复数值：对方手卡数量乘以500
	local rt=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)*500
	-- 获取当前连锁设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行回复操作，使目标玩家回复计算出的生命值
	Duel.Recover(p,rt,REASON_EFFECT)
end
