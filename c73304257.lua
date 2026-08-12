--獣王アルファ
-- 效果：
-- 这张卡不能通常召唤。对方场上的怪兽的攻击力合计比自己场上的怪兽的攻击力合计高的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：以自己场上的兽族·兽战士族·鸟兽族怪兽任意数量为对象才能发动。那些怪兽回到手卡。那之后，选回到手卡的数量的对方场上的表侧表示怪兽回到手卡。这个效果的发动后，直到回合结束时自己的「兽王 阿尔法」不能直接攻击。
function c73304257.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。对方场上的怪兽的攻击力合计比自己场上的怪兽的攻击力合计高的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c73304257.sprcon)
	c:RegisterEffect(e1)
	-- ①：以自己场上的兽族·兽战士族·鸟兽族怪兽任意数量为对象才能发动。那些怪兽回到手卡。那之后，选回到手卡的数量的对方场上的表侧表示怪兽回到手卡。这个效果的发动后，直到回合结束时自己的「兽王 阿尔法」不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73304257,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,73304257)
	e2:SetTarget(c73304257.thtg)
	e2:SetOperation(c73304257.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件函数：检查怪兽区域空格以及双方场上表侧表示怪兽的攻击力合计
function c73304257.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 获取自己场上所有表侧表示的怪兽
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有表侧表示的怪兽
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return g1:GetSum(Card.GetAttack)<g2:GetSum(Card.GetAttack)
end
-- 过滤条件：自己场上表侧表示的兽族、兽战士族或鸟兽族且能回到手牌的怪兽
function c73304257.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 过滤条件：满足thfilter条件且可以作为效果对象的怪兽
function c73304257.thfilter1(c,e)
	return c73304257.thfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 过滤条件：对方场上表侧表示且能回到手牌的怪兽
function c73304257.thfilter2(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果①的发动准备：检查并选择自己场上的怪兽作为对象，并设置操作信息
function c73304257.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c73304257.thfilter(chkc) end
	-- 计算自己场上满足条件且可作为效果对象的怪兽数量
	local ct1=Duel.GetMatchingGroupCount(c73304257.thfilter1,tp,LOCATION_MZONE,0,nil,e)
	-- 计算对方场上满足条件的表侧表示怪兽数量
	local ct2=Duel.GetMatchingGroupCount(c73304257.thfilter2,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return ct1>0 and ct2>0 end
	local ct=math.min(ct1,ct2)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张到ct张满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73304257.thfilter,tp,LOCATION_MZONE,0,1,ct,nil)
	-- 设置操作信息：将选中的对象怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果①的效果处理：将对象怪兽送回手牌，再将相同数量的对方场上怪兽送回手牌，并适用不能直接攻击的限制
function c73304257.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若存在相关对象，则将其送回手牌，并检查是否成功送回
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 获取上一步操作中实际被送回手牌的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		-- 若实际回到手牌的卡片数量大于0，且对方场上存在至少该数量的表侧表示怪兽
		if ct>0 and Duel.IsExistingMatchingCard(c73304257.thfilter2,tp,0,LOCATION_MZONE,ct,nil) then
			-- 中断当前效果处理，使后续的“那之后”处理与前面的“回到手卡”不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 让玩家选择与回到手牌数量相同的对方场上的表侧表示怪兽
			local hg=Duel.SelectMatchingCard(tp,c73304257.thfilter2,tp,0,LOCATION_MZONE,ct,ct,nil)
			-- 对选中的对方怪兽进行闪烁提示
			Duel.HintSelection(hg)
			-- 将选中的对方怪兽送回手牌
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己的「兽王 阿尔法」不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置不能直接攻击效果的影响对象为卡名为「兽王 阿尔法」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,73304257))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该不能直接攻击的限制效果
	Duel.RegisterEffect(e1,tp)
end
