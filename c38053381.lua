--王の舞台
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，对方从卡组把卡加入手卡的场合才能发动。从卡组把1只「王战」怪兽守备表示特殊召唤。
-- ②：对方回合，自己对「王战」怪兽的特殊召唤成功的场合才能发动。在自己场上把「王战团队衍生物」（天使族·光·4星·攻/守1500）尽可能攻击表示特殊召唤。这衍生物在结束阶段破坏。
function c38053381.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方从卡组把卡加入手卡的场合才能发动。从卡组把1只「王战」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38053381,0))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c38053381.spcon)
	e2:SetTarget(c38053381.sptg)
	e2:SetOperation(c38053381.spop)
	c:RegisterEffect(e2)
	-- ②：对方回合，自己对「王战」怪兽的特殊召唤成功的场合才能发动。在自己场上把「王战团队衍生物」（天使族·光·4星·攻/守1500）尽可能攻击表示特殊召唤。这衍生物在结束阶段破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38053381,1))  --"特殊召唤衍生物"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,38053381)
	e3:SetCondition(c38053381.tkcon)
	e3:SetTarget(c38053381.tktg)
	e3:SetOperation(c38053381.tkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断卡是否为对方从卡组加入手牌
function c38053381.cfilter1(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果条件，判断是否有对方从卡组加入手牌的卡
function c38053381.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38053381.cfilter1,1,nil,1-tp)
end
-- 过滤函数，用于判断卡是否为「王战」怪兽且可特殊召唤
function c38053381.spfilter(c,e,tp)
	return c:IsSetCard(0x134) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的处理，判断是否满足特殊召唤条件
function c38053381.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「王战」怪兽
		and Duel.IsExistingMatchingCard(c38053381.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理，选择并特殊召唤1只「王战」怪兽
function c38053381.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「王战」怪兽
	local g=Duel.SelectMatchingCard(tp,c38053381.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数，用于判断卡是否为己方「王战」怪兽且处于表侧表示
function c38053381.cfilter2(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0x134) and c:IsFaceup()
end
-- 效果条件，判断是否为对方回合且己方有「王战」怪兽特殊召唤成功
function c38053381.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合且己方有「王战」怪兽特殊召唤成功
	return Duel.GetTurnPlayer()~=tp and eg:IsExists(c38053381.cfilter2,1,nil,tp)
end
-- 效果发动时的处理，判断是否满足特殊召唤衍生物条件
function c38053381.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38053382,0x134,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) end
	-- 获取己方场上可用的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置效果发动时的操作信息，表示将召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置效果发动时的操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 效果发动时的处理，特殊召唤衍生物并设置其在结束阶段破坏
function c38053381.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足特殊召唤衍生物的条件
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,38053382,0x134,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		-- 创建「王战团队衍生物」
		local token=Duel.CreateToken(tp,38053382)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		token:RegisterFlagEffect(38053381,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		g:AddCard(token)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 注册一个在结束阶段触发的效果，用于破坏衍生物
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c38053381.descon)
	e1:SetOperation(c38053381.desop)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于判断衍生物是否为本次特殊召唤的衍生物
function c38053381.desfilter(c,fid)
	return c:GetFlagEffectLabel(38053381)==fid
end
-- 判断是否还有本次特殊召唤的衍生物存在
function c38053381.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c38053381.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 效果发动时的处理，破坏衍生物
function c38053381.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c38053381.desfilter,nil,e:GetLabel())
	-- 将衍生物破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
