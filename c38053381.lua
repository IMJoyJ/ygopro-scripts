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
	-- 对应效果原文①：『①：1回合1次，对方从卡组把卡加入手卡的场合才能发动。从卡组把1只「王战」怪兽守备表示特殊召唤。』
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
	-- 对应效果原文卡名限制及②：『这个卡名的②的效果1回合只能使用1次。』『②：对方回合，自己对「王战」怪兽的特殊召唤成功的场合才能发动。在自己场上把「王战团队衍生物」（天使族·光·4星·攻/守1500）尽可能攻击表示特殊召唤。这衍生物在结束阶段破坏。』
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
-- 过滤函数：判断卡片当前控制者为tp，且移动前所在区域为卡组，即用于检测『从卡组加入手卡』的卡。
function c38053381.cfilter1(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 触发条件：本次加入手卡的怪兽群中存在由对方控制且从卡组加入手卡的卡。
function c38053381.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38053381.cfilter1,1,nil,1-tp)
end
-- 筛选卡组中持有「王战」字段且能够被当前效果以表侧守备表示特殊召唤的怪兽。
function c38053381.spfilter(c,e,tp)
	return c:IsSetCard(0x134) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时合法性检查：自己主要怪兽区有空位，且卡组中存在符合特殊召唤条件的「王战」怪兽。
function c38053381.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件之一：自己主要怪兽区存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件之一：卡组中存在满足特殊召唤条件的「王战」怪兽。
		and Duel.IsExistingMatchingCard(c38053381.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理涉及从卡组特殊召唤1只怪兽，供连锁判定等系统使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区仍有空位，则从卡组选择1只「王战」怪兽以表侧守备表示特殊召唤。
function c38053381.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的「王战」怪兽。
	local g=Duel.SelectMatchingCard(tp,c38053381.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数：判断卡片是由tp玩家特殊召唤成功、持有「王战」字段且处于表侧表示。
function c38053381.cfilter2(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0x134) and c:IsFaceup()
end
-- ②触发条件：当前为对方回合，且本次特殊召唤成功的怪兽中有自己控制的表侧表示「王战」怪兽。
function c38053381.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是对方回合，且特殊召唤成功的怪兽中包含由自己特殊召唤成功的表侧「王战」怪兽。
	return Duel.GetTurnPlayer()~=tp and eg:IsExists(c38053381.cfilter2,1,nil,tp)
end
-- ②效果发动时合法性检查：自己主要怪兽区有空位，且自己能够特殊召唤「王战团队衍生物」。
function c38053381.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②发动条件之一：自己主要怪兽区存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ②发动条件之一：自己可以特殊召唤「王战团队衍生物」（天使族·光·4星·攻/守1500）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38053382,0x134,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) end
	-- 取得自己主要怪兽区的可用区域数量，用于确定最多可特殊召唤的衍生物数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置操作信息：本次效果涉及生成衍生物，预计数量为ft。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置操作信息：本次效果涉及特殊召唤衍生物，预计数量为ft。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 效果处理：计算可用区域后，生成尽可能多的「王战团队衍生物」以表侧攻击表示特殊召唤，并在结束阶段破坏；若场上存在青眼精灵龙则数量限制为1。
function c38053381.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时取得当前主要怪兽区可用区域数量，决定实际特殊召唤的衍生物只数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若可用区域为0或无法特殊召唤「王战团队衍生物」，则效果不处理。
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,38053382,0x134,TYPES_TOKEN_MONSTER,1500,1500,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		-- 生成1只「王战团队衍生物」（卡号38053382）的衍生物。
		local token=Duel.CreateToken(tp,38053382)
		-- 以表侧攻击表示将衍生物特殊召唤（分步特殊召唤处理中的一步）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		token:RegisterFlagEffect(38053381,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		g:AddCard(token)
	end
	-- 结束分步特殊召唤处理，统一完成所有衍生物的特殊召唤。
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 对应效果原文结尾：『这衍生物在结束阶段破坏。』
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c38053381.descon)
	e1:SetOperation(c38053381.desop)
	-- 将结束阶段破坏衍生物的效果注册到场上，使其在结束阶段执行。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：判断卡片是否带有本次特殊召唤时设置的标识fid，用于识别这批发衍生物。
function c38053381.desfilter(c,fid)
	return c:GetFlagEffectLabel(38053381)==fid
end
-- 结束阶段破坏的触发条件：记录中的衍生物仍有至少1只存在于场上；若全部离场则清理该效果并停止执行。
function c38053381.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c38053381.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏的处理：取出仍带有对应标识的衍生物，将其破坏。
function c38053381.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c38053381.desfilter,nil,e:GetLabel())
	-- 以效果原因将衍生物破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
