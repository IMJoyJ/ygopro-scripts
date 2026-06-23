--ラーニング・エルフ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把持有把自身当作装备卡使用来装备效果的1张陷阱卡从卡组到自己场上盖放。
-- ②：这张卡从场上送去墓地的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 创建并注册学习精灵的两个诱发效果，分别对应召唤和特殊召唤时的盖放陷阱效果，以及送去墓地时的抽卡效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。把持有把自身当作装备卡使用来装备效果的1张陷阱卡从卡组到自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放效果"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 定义一个过滤函数，用于判断效果是否包含装备类别
function s.equip_filter(e)
	return e:IsHasCategory(CATEGORY_EQUIP)
end
-- 定义一个过滤函数，用于筛选可以盖放的陷阱卡，要求是陷阱卡、可以盖放且具有装备效果
function s.ssfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable() and c:IsOriginalEffectProperty(s.equip_filter)
end
-- 盖放效果的发动时点处理函数，检查场上是否有空位并确认卡组中是否存在符合条件的陷阱卡
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在符合条件的陷阱卡
		and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的发动处理函数，选择并盖放一张符合条件的陷阱卡
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上魔陷区是否还有空位，如果没有则不执行盖放
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张符合条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡盖放到场上
		Duel.SSet(tp,g)
	end
end
-- 抽卡效果的发动条件函数，判断该卡是否从场上送去墓地
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 抽卡效果的目标设定函数，设置目标玩家和抽卡数量
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的发动处理函数，执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，抽卡原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
