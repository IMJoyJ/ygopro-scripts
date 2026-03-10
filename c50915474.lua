--表裏の女神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「表里之女神」以外的1只持有进行投掷硬币效果的怪兽加入手卡。
-- ②：自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，自己场上的全部怪兽的攻击力直到回合结束时变成2倍。猜错的场合，自己场上的怪兽全部送去墓地，自己抽1张。
local s,id,o=GetID()
-- 创建并注册表里之女神的两个触发效果，分别对应通常召唤和特殊召唤时的检索效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「表里之女神」以外的1只持有进行投掷硬币效果的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，自己场上的全部怪兽的攻击力直到回合结束时变成2倍。猜错的场合，自己场上的怪兽全部送去墓地，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"猜硬币"
	e3:SetCategory(CATEGORY_COIN+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤器函数，用于筛选卡组中非自身且具有投掷硬币效果的怪兽
function s.thfilter(c)
	-- 筛选条件：不是自身、拥有投掷硬币效果、是怪兽类型、可以加入手牌
	return not c:IsCode(id) and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标函数，检查是否满足检索条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作函数，选择并处理检索的卡片
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置猜硬币效果的目标函数，检查是否可以抽卡并设置操作信息
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息为投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,0)
end
-- 定义猜硬币时用于筛选场上怪兽的过滤器函数
function s.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
-- 执行猜硬币效果的操作函数，处理猜硬币结果及后续效果
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择硬币正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 投掷一次硬币
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 获取满足条件的场上怪兽组
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
		-- 遍历场上符合条件的怪兽
		for tc in aux.Next(g) do
			-- 对场上每个符合条件的怪兽，设置其攻击力变为原来的2倍
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(tc:GetAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		-- 获取所有场上的怪兽组
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
		-- 将场上所有怪兽送去墓地并检查是否成功
		if g:GetCount()==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
		-- 统计被送去墓地的卡数量
		local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if oc==0 then return end
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
