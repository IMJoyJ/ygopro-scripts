--ジャンク・スピーダー
-- 效果：
-- 「同调士」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。从卡组把「同调士」调整尽可能守备表示特殊召唤（相同等级最多1只）。
-- ②：这个回合同调召唤的这张卡和怪兽进行战斗的攻击宣言时才能发动。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
function c77075360.initial_effect(c)
	-- 添加同调召唤手续：以「同调士」调整为素材，加上1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,c77075360.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。从卡组把「同调士」调整尽可能守备表示特殊召唤（相同等级最多1只）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77075360,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,77075360)
	e1:SetCost(c77075360.spcost)
	e1:SetCondition(c77075360.spcon)
	e1:SetTarget(c77075360.sptg)
	e1:SetOperation(c77075360.spop)
	c:RegisterEffect(e1)
	-- ②：这个回合同调召唤的这张卡和怪兽进行战斗的攻击宣言时才能发动。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c77075360.spcon)
	e2:SetOperation(c77075360.regop)
	c:RegisterEffect(e2)
	-- 注册特殊召唤活动计数器，用于追踪玩家在该回合内是否从额外卡组特殊召唤了非同调怪兽
	Duel.AddCustomActivityCounter(77075360,ACTIVITY_SPSUMMON,c77075360.counterfilter)
end
c77075360.material_setcode=0x1017
-- 过滤作为同调素材的调整怪兽：属于「同调士」系列，或适用同调召唤替代效果的怪兽
function c77075360.tfilter(c)
	return c:IsSetCard(0x1017) or c:IsHasEffect(20932152)
end
-- 计数器过滤条件：如果从额外卡组特殊召唤了非同调怪兽，则该计数器值会增加
function c77075360.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果①的发动代价：检查并注册本回合不能从额外卡组特殊召唤非同调怪兽的誓约效果
function c77075360.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合在此效果发动前是否曾从额外卡组特殊召唤过非同调怪兽
	if chk==0 then return Duel.GetCustomActivityCount(77075360,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：这张卡同调召唤的场合才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。从卡组把「同调士」调整尽可能守备表示特殊召唤（相同等级最多1只）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c77075360.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为效果发动玩家注册禁止从额外卡组特殊召唤非同调怪兽的誓约限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能从额外卡组特殊召唤非同调怪兽
function c77075360.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：这张卡同调召唤成功时
function c77075360.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤可以特殊召唤的怪兽：卡组中可以守备表示特殊召唤的「同调士」调整怪兽
function c77075360.filter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动检查与效果注册：检查怪兽区域空位与卡组中可召唤的卡，并设置特殊召唤的操作信息
function c77075360.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「同调士」调整怪兽
		and Duel.IsExistingMatchingCard(c77075360.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表明此效果包含从卡组特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将互不相同等级的「同调士」调整怪兽尽可能守备表示特殊召唤到场上
function c77075360.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取卡组中所有可以被特殊召唤的「同调士」调整怪兽的卡片组
	local g=Duel.GetMatchingGroup(c77075360.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=math.min(g:GetClassCount(Card.GetLevel),ft)
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设定卡组选择时的校验函数为所选卡片的等级互不相同
	aux.GCheckAdditional=aux.dlvcheck
	-- 由玩家选择符合数量上限且等级互不相同的怪兽卡片组
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,ct,ct)
	-- 特殊召唤怪兽选择完毕后，将校验函数还原
	aux.GCheckAdditional=nil
	-- 将选择好的怪兽以守备表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 注册效果②的发动时点效果：当此卡同调召唤成功时，注册一个在进行战斗的攻击宣言时可以发动的诱发效果
function c77075360.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这个回合同调召唤的这张卡和怪兽进行战斗的攻击宣言时才能发动。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77075360,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,77075361)
	e1:SetCondition(c77075360.atkcon)
	e1:SetOperation(c77075360.atkop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 效果②的发动条件：进行战斗的攻击宣言时，此卡是攻击怪兽或被攻击的目标怪兽
function c77075360.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否是攻击怪兽且存在攻击对象，或者此卡是被攻击的怪兽
	return c==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil or c==Duel.GetAttackTarget()
end
-- 效果②的效果处理：若此卡仍在场且表侧表示，则将其攻击力直到回合结束时变成原本攻击力的2倍
function c77075360.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
