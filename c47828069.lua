--レイズ・ムーンの翼 ラピ
local s,id,o=GetID()
-- 初始化卡片效果：注册抽卡特召、登场抽卡及对方回合超量召唤效果，并注册全局检索监测
function s.initial_effect(c)
	-- ①：抽到这张卡时，把这张卡给对方出示才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡召唤·特殊召唤的场合才能发动（欲发动这个效果的回合，自己不能用抽卡以外的方法从卡组把卡加入手卡）。自己抽1张。这个效果的发动后，直到回合结束时自己从额外卡组只能特殊召唤光属性超量怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.drcon)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：对方回合1次，才能发动。进行1只光属性·7阶超量怪兽的超量召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.xyzcon)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 欲发动这个效果的回合，自己不能用抽卡以外的方法从卡组把卡加入手卡
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果：监听卡片加入手牌事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局事件处理：检测非抽卡方式从卡组将卡加入手牌并为玩家注册标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历加入手牌的卡片组
	for tc in aux.Next(eg) do
		if not tc:IsReason(REASON_DRAW) and tc:IsPreviousLocation(LOCATION_DECK) then
			-- 为操作玩家注册标记，记录本回合曾将卡从卡组加入手卡
			Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 效果发动代价：向对方出示手牌中的这张卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 特殊召唤效果的目标判定及操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件：从手牌召唤·特殊召唤成功
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- 效果发动代价：确认本回合未曾从卡组将卡加入手牌，并施加本回合不能从卡组将卡加入手牌的誓约
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未进行过抽卡以外的检索
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 欲发动这个效果的回合，自己不能用抽卡以外的方法从卡组把卡加入手卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	-- 设置不能加入手牌的卡片范围为卡组
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能从卡组将卡加入手牌的效果
	Duel.RegisterEffect(e1,tp)
end
-- 抽卡效果的目标设定及操作信息设置
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
end
-- 效果处理：抽1张卡，并施加从额外卡组只能特殊召唤光属性超量怪兽的限制
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 这个效果的发动后，直到回合结束时自己从额外卡组只能特殊召唤光属性超量怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册直到回合结束时的额外特召限制
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：非光属性超量怪兽不能从额外卡组特殊召唤
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- 超量召唤效果的发动条件判定
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤可进行超量召唤的光属性·7阶超量怪兽
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRank(7) and c:IsXyzSummonable(nil)
end
-- 超量召唤效果的目标判定及操作信息设置
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以超量召唤的光属性7阶超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
end
-- 效果处理：进行光属性7阶超量怪兽的超量召唤
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有满足超量召唤条件的光属性7阶超量怪兽
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 对选中的怪兽进行超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
