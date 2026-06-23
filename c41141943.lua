--超重武者ヒキャ－Q
-- 效果：
-- 「超重武者 飞脚-Q」的②的效果1回合只能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。从手卡把最多2只怪兽在对方场上守备表示特殊召唤。那之后，自己从卡组抽出这个效果特殊召唤的怪兽的数量。
function c41141943.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41141943,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c41141943.hspcon)
	e1:SetOperation(c41141943.hspop)
	c:RegisterEffect(e1)
	-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。从手卡把最多2只怪兽在对方场上守备表示特殊召唤。那之后，自己从卡组抽出这个效果特殊召唤的怪兽的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41141943)
	e2:SetCondition(c41141943.spcon)
	e2:SetCost(c41141943.spcost)
	e2:SetTarget(c41141943.sptg)
	e2:SetOperation(c41141943.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地是否存在魔法·陷阱卡
function c41141943.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断手卡特殊召唤的条件：场上存在空位且自己墓地没有魔法·陷阱卡
function c41141943.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(c41141943.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 创建并注册一个永续效果，使自己不能特殊召唤非「超重武者」怪兽
function c41141943.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册效果给玩家
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41141943.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 限制非「超重武者」怪兽不能特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 判断对方墓地是否存在魔法·陷阱卡
function c41141943.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- 判断自己墓地是否存在魔法·陷阱卡
function c41141943.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地是否存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c41141943.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 判断是否可以支付解放作为代价
function c41141943.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于判断手卡中可特殊召唤的怪兽
function c41141943.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 设置发动效果时的条件检查
function c41141943.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判断自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1)
		-- 判断自己手卡中是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c41141943.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理时要抽卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果发动后的操作：选择怪兽特殊召唤并抽卡
function c41141943.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的可特殊召唤怪兽组
	local g=Duel.GetMatchingGroup(c41141943.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 计算最多可特殊召唤的怪兽数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if g:GetCount()==0 or ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,ft,nil)
	-- 将选择的怪兽特殊召唤到对方场上
	local ct=Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	if ct>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 从卡组抽指定数量的卡
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
