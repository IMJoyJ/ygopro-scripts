--竜騎士アトリィ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，若「徽记」卡和「百夫长骑士」卡各在自己墓地存在则能发动。自己抽1张。这个回合，自己不能把「龙骑士 阿特莉」特殊召唤。
-- ②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，若「徽记」卡和「百夫长骑士」卡各在自己墓地存在则能发动。自己抽1张。这个回合，自己不能把「龙骑士 阿特莉」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽1张"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetValue(s.tnval)
	c:RegisterEffect(e3)
	-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+o)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地中是否存在「徽记」卡，且同时存在另一张「百夫长骑士」卡。
function s.drfilter(c,tp)
	return c:IsSetCard(0x1b3)
		-- 检查自己墓地是否存在除了当前卡以外的「百夫长骑士」卡。
		and Duel.IsExistingMatchingCard(s.drfilter2,tp,LOCATION_GRAVE,0,1,c)
end
-- 过滤「百夫长骑士」卡的辅助函数。
function s.drfilter2(c)
	return c:IsSetCard(0x1a2)
end
-- 抽卡效果的发动条件检查与效果处理目标设定。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡，以及自己墓地是否各存在「徽记」卡和「百夫长骑士」卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 将当前连锁的对象玩家设定为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设定为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理，并对自身施加本回合不能特殊召唤同名卡的限制。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
	-- 这个回合，自己不能把「龙骑士 阿特莉」特殊召唤。/可以把这张卡当作调整以外的怪兽使用。/这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该回合内不能特殊召唤「龙骑士 阿特莉」的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的卡片过滤函数，指定为本卡（龙骑士 阿特莉）。
function s.splimit(e,c)
	return c:IsCode(id)
end
-- 判定作为同调素材时，是否由本卡的控制者进行同调召唤。
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- 特殊召唤效果的发动条件：必须在自己或对方的主要阶段，且这张卡当作永续陷阱卡使用。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位及是否可以特殊召唤自身。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤具有本卡属性、等级、攻防等数值的怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT+TYPE_TUNER,1800,1400,4,RACE_DRAGON,ATTRIBUTE_DARK) end
	-- 设置当前连锁的操作信息为：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
