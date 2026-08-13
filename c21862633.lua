--切り裂かれし闇
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己对衍生物以外的通常怪兽的召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：以下其中任意种的自己怪兽在和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。
-- ●5星以上的通常怪兽
-- ●使用通常怪兽作仪式召唤的怪兽
-- ●通常怪兽为素材作融合·同调·超量召唤的怪兽
function c21862633.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己把衍生物以外的通常怪兽召唤·特殊召唤的场合才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21862633,0))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,21862633)
	e2:SetCondition(c21862633.drcon)
	e2:SetTarget(c21862633.drtg)
	e2:SetOperation(c21862633.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：以下其中任意种的自己怪兽在和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。●5星以上的通常怪兽 ●使用通常怪兽作仪式召唤的怪兽 ●通常怪兽为素材作融合·同调·超量召唤的怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21862633,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,21862634)
	e4:SetCondition(c21862633.atkcon)
	e4:SetOperation(c21862633.atkop)
	c:RegisterEffect(e4)
	if not c21862633.global_check then
		c21862633.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次。①：自己把衍生物以外的通常怪兽召唤·特殊召唤的场合才能发动。自己抽1张。②：以下其中任意种的自己怪兽在和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。●5星以上的通常怪兽 ●使用通常怪兽作仪式召唤的怪兽 ●通常怪兽为素材作融合·同调·超量召唤的怪兽。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c21862633.valcheck)
		-- 将全局素材检查效果注册到环境（player=0表示全场），在怪兽被用作素材时调用valcheck进行标记，以支持②效果对特定召唤方式怪兽的识别。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 素材检查回调函数：取得该次召唤/特殊召唤所用的素材组g，若其中存在通常怪兽，则在此被召唤出的怪兽c身上标记flag 21862633，表示该怪兽使用通常怪兽作为素材，标记在怪兽离场或翻面等重置事件后清除。
function c21862633.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		c:RegisterFlagEffect(21862633,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 过滤函数：判断一只怪兽是否为表侧表示、通常怪兽、由tp玩家召唤/特殊召唤成功，且不是衍生物；用于①效果的召唤·特殊召唤成功判定。
function c21862633.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsSummonPlayer(tp) and not c:IsType(TYPE_TOKEN)
end
-- ①效果的发动条件：本次召唤/特殊召唤成功的事件组eg中存在至少1只满足cfilter的怪兽（即tp玩家成功召唤/特殊召唤了非衍生物通常怪兽）时，允许发动。
function c21862633.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21862633.cfilter,1,nil,tp)
end
-- ①效果发动时的目标处理：在发动合法性检查时确认tp玩家可以抽卡，然后将抽卡玩家和数量（tp、1）写入连锁对象，并设置操作信息为抽1张卡，供后续处理及干扰检测使用。
function c21862633.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时的合法性检查（chk=0）中，判定tp玩家是否允许抽1张卡；若不允许则禁止发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为tp（自己），表示抽卡动作的受益者是tp。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示要抽的卡数为1张。
	Duel.SetTargetParam(1)
	-- 登记本次连锁的操作信息：分类为抽卡效果，将由tp玩家抽1张卡（目标卡未指定），用于让其他卡正确响应抽卡行为。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理阶段：先从连锁信息中取出之前记录的对象玩家p和抽卡数量d，再执行Duel.Draw让p抽d张卡，抽卡原因记为效果。
function c21862633.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前正在处理的连锁信息中取出CHAININFO_TARGET_PLAYER（对象玩家）和CHAININFO_TARGET_PARAM（对象参数），分别赋值给p和d，供后续抽卡使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p抽取d张卡，原因为效果（REASON_EFFECT）；若存在‘不能抽卡’等限制，实际抽取数量可能减少。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②效果的发动条件：己方战斗怪兽a与对方战斗怪兽at进行攻击宣言时，要求at攻击力>0，且a满足下述任一条件：a为5星以上通常怪兽；或a带‘素材含通常怪兽’标记且a的召唤方式为仪式/融合/同调/超量召唤，此时才允许发动。
function c21862633.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取控制者为tp的正在战斗的己方怪兽a及与其战斗的对方怪兽at，用于判断攻击力及怪兽种类。
	local a,at=Duel.GetBattleMonster(tp)
	return a and at and at:GetAttack()>0 and (a:IsType(TYPE_NORMAL) and a:IsLevelAbove(5)
		or a:GetFlagEffect(21862633)>0 and (a:IsSummonType(SUMMON_TYPE_RITUAL)
			or a:IsSummonType(SUMMON_TYPE_FUSION)
			or a:IsSummonType(SUMMON_TYPE_SYNCHRO)
			or a:IsSummonType(SUMMON_TYPE_XYZ)))
end
-- ②效果处理：重新确认正在战斗的双方怪兽a和at仍存在于场上且表侧表示、与战斗相关；满足后为a注册一个单体效果，使其攻击力直到回合结束时上升at当前的攻击力数值。
function c21862633.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取己方战斗怪兽a与对方战斗怪兽at，防止发动后原怪兽状态变化，确保上升的是当前正确的对方怪兽攻击力。
	local a,at=Duel.GetBattleMonster(tp)
	if not a or not at or not a:IsRelateToBattle() or a:IsFacedown() or not at:IsRelateToBattle() or at:IsFacedown() then return end
	-- 那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(at:GetAttack())
	a:RegisterEffect(e1)
end
