--レイズ・ムーンの天 シエロ－ノーモアベット
local s,id,o=GetID()
-- 初始化卡片效果，设置超量召唤手续、素材限制及效果①②③④
function s.initial_effect(c)
	-- 设置超量召唤手续：7星「升月」怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1ec),7,2)
	c:EnableReviveLimit()
	-- 这张卡不能作为融合·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetValue(s.fuslimit)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e3)
	-- ①：额外怪兽区域的这张卡不受其他卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.imcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ②：额外怪兽区域的这张卡存在，对方把包含抽卡或从卡组把卡加入手卡效果的效果发动时才能发动。那个效果变成「对方抽1张」。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.drcon)
	e5:SetOperation(s.drop)
	c:RegisterEffect(e5)
	-- ③：1回合1次，额外怪兽区域的这张卡把1个超量素材取除才能发动。自己抽1张。这个效果在对方回合也能发动。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMING_CHAIN_END)
	e6:SetCountLimit(1)
	e6:SetCondition(s.imcon)
	e6:SetCost(s.drcost2)
	e6:SetTarget(s.drtg2)
	e6:SetOperation(s.drop2)
	c:RegisterEffect(e6)
	-- ④：这张卡被对方送去墓地的场合才能发动。自己抽1张。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(s.drcon2)
	e7:SetTarget(s.drtg2)
	e7:SetOperation(s.drop2)
	c:RegisterEffect(e7)
end
-- 融合召唤素材限制判断
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 检查自身是否位于额外怪兽区域
function s.imcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 效果变更的发动条件：连锁处理时对方发动的效果包含抽卡或检索且对方可抽卡，且自身位于额外怪兽区
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	-- 检查对方发动的效果是否包含抽卡或检索且对方可以抽卡
	return (ex4 or ex5) and rp==1-tp and Duel.IsPlayerCanDraw(1-tp,1)
		and e:GetHandler():GetSequence()>4
end
-- 效果处理：将当前连锁的效果处理变更为对方抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家选择是否适用效果变更
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
		-- 显示卡片发动提示
		Duel.Hint(HINT_CARD,0,id)
		local g=Group.CreateGroup()
		-- 清空该连锁的对象卡片
		Duel.ChangeTargetCard(ev,g)
		-- 将该连锁的操作处理替换为目标函数
		Duel.ChangeChainOperation(ev,s.repop)
	end
end
-- 变更后的效果处理：对方抽1张卡
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行效果抽卡1张
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 发动Cost：取除这张卡的1个超量素材
function s.drcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 抽卡效果发动准备与操作信息设置
function s.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡操作的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：自己抽1张卡
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 发动的条件：因对方被送去墓地
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
