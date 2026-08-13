--幻銃士
-- 效果：
-- ①：这张卡召唤·反转召唤成功时才能发动。把最多有自己场上的怪兽数量的「铳士衍生物」（恶魔族·暗·4星·攻/守500）在自己场上特殊召唤。
-- ②：自己准备阶段才能发动。给与对方为自己场上的「铳士」怪兽数量×300伤害。这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
function c12958919.initial_effect(c)
	-- ①：这张卡召唤·反转召唤成功时才能发动。把最多有自己场上的怪兽数量的「铳士衍生物」（恶魔族·暗·4星·攻/守500）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12958919,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c12958919.sptg)
	e1:SetOperation(c12958919.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段才能发动。给与对方为自己场上的「铳士」怪兽数量×300伤害。这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12958919,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c12958919.damcon)
	e2:SetCost(c12958919.damcost)
	e2:SetTarget(c12958919.damtg)
	e2:SetOperation(c12958919.damop)
	c:RegisterEffect(e2)
	if not c12958919.global_check then
		c12958919.global_check=true
		-- 这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c12958919.checkop)
		-- 将全局检查效果ge1注册到全场（玩家0），该效果会在每次攻击宣言时触发，用于记录「铳士」怪兽的攻击宣言。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时点的检查操作：若攻击宣言的怪兽是「铳士」字段怪兽，则给其控制者注册一个本回合的flag标记。
function c12958919.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSetCard(0x49) then
		-- 为攻击宣言的「铳士」怪兽的控制者注册标记12958919，持续到回合结束，用于表示该玩家本回合已有「铳士」怪兽进行过攻击宣言。
		Duel.RegisterFlagEffect(tc:GetControler(),12958919,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ①效果的发动条件与目标处理（选发效果）：检查自己场上是否有空余的主要怪兽区，以及自己是否能够特殊召唤「铳士衍生物」。
function c12958919.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0为发动合法性检测），要求自己主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己能够特殊召唤满足指定参数的「铳士衍生物」（恶魔族·暗·4星·攻/守500，含「铳士」字段，衍生物类型）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,12958920,0x49,TYPES_TOKEN_MONSTER,500,500,4,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：本效果涉及衍生物生成，预计生成1只衍生物（位置未定，因为数量由处理时自己场上怪兽数量决定）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果涉及特殊召唤，预计特殊召唤1只衍生物（数量不确定，由处理时决定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果处理：计算特殊召唤的数量（最多为场上怪兽数量且不超过可用区域），逐只生成「铳士衍生物」并特殊召唤，每只由玩家确认是否继续。
function c12958919.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区的可用空格数，作为最多可特殊召唤的衍生物数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己场上（主要怪兽区）当前存在的怪兽数量，用于决定衍生物的最大数量。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 处理时再次确认自己能否特殊召唤「铳士衍生物」，若不能则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,12958920,0x49,TYPES_TOKEN_MONSTER,500,500,4,RACE_FIEND,ATTRIBUTE_DARK) then return end
	local ctn=true
	while ft>0 and ctn do
		-- 在场上生成1只「铳士衍生物」（卡号12958920）。
		local token=Duel.CreateToken(tp,12958920)
		-- 将衍生物以表侧攻击表示特殊召唤（作为多只同时特殊召唤的步骤之一）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
		-- 如果已特殊召唤满预定数量，或玩家选择不再继续生成，则停止循环。0x49字段的「铳士」衍生物可以继续特殊召唤，直到上限或玩家取消。
		if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(12958919,2)) then ctn=false end  --"是否还要特殊召唤Token？"
	end
	-- 完成所有衍生物的特殊召唤处理，触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：只有在自己准备阶段（且自己为回合玩家）时才能发动。
function c12958919.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否是回合玩家（即准备阶段属于自己时）。
	return tp==Duel.GetTurnPlayer()
end
-- ②效果的发动代价检查与执行：本回合没有「铳士」怪兽攻击宣言过（flag检测），发动时给自己场上的「铳士」怪兽附加本回合不能攻击宣言的限制。
function c12958919.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检测：要求本回合自己没有「铳士」怪兽进行过攻击宣言（无flag标记）。
	if chk==0 then return Duel.GetFlagEffect(tp,12958919)==0 end
	-- 这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	-- 设定该限制效果的对象筛选：只影响「铳士」（0x49）字段的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x49))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能攻击宣言”的永续效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害数量统计的过滤条件：表侧表示的「铳士」字段怪兽。
function c12958919.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x49)
end
-- ②效果的目标设定：不取对象，设定伤害对象为对方玩家，并预设伤害值为自己场上符合条件的「铳士」怪兽数量×300。
function c12958919.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计自己场上表侧表示且属于「铳士」字段的怪兽数量，用于计算伤害。
	local ct=Duel.GetMatchingGroupCount(c12958919.damfilter,tp,LOCATION_MZONE,0,nil)
	-- 将当前连锁的对象玩家设为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：本效果将造成伤害，伤害类别为效果伤害，对象玩家为对方，数值为当前统计数量×300。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- ②效果处理：获取目标玩家（对方），重新统计伤害计算所需的「铳士」怪兽数量，并对对方造成数量×300的效果伤害。
function c12958919.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新统计自己场上表侧表示的「铳士」怪兽数量，以确定实际伤害值。
	local ct=Duel.GetMatchingGroupCount(c12958919.damfilter,tp,LOCATION_MZONE,0,nil)
	-- 对玩家p造成ct×300点效果伤害。
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
