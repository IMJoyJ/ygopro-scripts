--レイズ・ムーンの雅 キャロル
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①②③及全局抽卡检查监听
function s.initial_effect(c)
	-- ①：抽到这张卡时，向对方展示这张卡才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成700。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(s.ntcon)
	e2:SetOperation(s.ntop)
	c:RegisterEffect(e2)
	-- ③：这张卡从手卡召唤·特殊召唤的场合才能发动。自己抽1张。这个回合，自己不是光属性·超量怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.drcon)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- （这个效果发动的回合，自己不能用抽卡以外的方法从卡组把卡加入手卡）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果：监听卡片加入手牌事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查是否有玩家在该回合通过抽卡以外的方式将卡组的卡加入手卡，若有则为该玩家注册标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历加入手牌的卡片组
	for tc in aux.Next(eg) do
		if not tc:IsReason(REASON_DRAW) and tc:IsPreviousLocation(LOCATION_DECK) then
			-- 给将卡加入手卡的玩家注册标记，持续到回合结束
			Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 发动Cost：展示手卡中的自身
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果发动条件及特殊召唤目标的确定
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将自身表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 不用解放作召唤的条件判断
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否无需解放且怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 将不用解放召唤的该卡的原本攻击力变为700
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的这张卡的原本攻击力变成700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(700)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 发动的条件：自身必须是从手卡召唤·特殊召唤
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- 发动Cost：检查本回合是否未曾用抽卡以外方式从卡组检索卡，并注册本回合检索限制
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否未曾以抽卡以外的方式从卡组将卡加入手卡
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- （这个效果发动的回合，自己不能用抽卡以外的方法从卡组把卡加入手卡）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	-- 设置限制目标位置为卡组
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册誓约效果：本回合不能从卡组把卡加入手卡
	Duel.RegisterEffect(e1,tp)
end
-- 抽卡效果的发动准备与操作信息设置
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡操作的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：自己抽1张卡，并注册额外卡组特殊召唤限制
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 这个回合，自己不是光属性·超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册限制：本回合不能从额外卡组特殊召唤光属性超量怪兽以外的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 过滤非光属性超量怪兽的额外卡组特殊召唤限制目标
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
